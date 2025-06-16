class BinPositionerService
  require 'csv'

  WIDTH_LIMIT = 2996 # max width per section
  HEIGHT_TOLERANCE = 254
  MAX_LEVELS = %w[00 01 02]
  SHALLOW_DEPTH_CUTOFF = 1524
  TALL_ARTICLE_THRESHOLD = 2000

  attr_reader :skipped_articles

  def initialize(aisle)
    @aisle = aisle
    @articles = Article.where(store_id: aisle.store_id, planned: [false, nil])
    @sections = aisle.sections.includes(:levels)
    @used_width_by_section_level = Hash.new(0)
    @max_height_by_level = Hash.new(0)
    @skipped_articles = []
  end

  def call
    Rails.logger.debug "[BinPositioner] Starting for Aisle ##{@aisle.id}"
    @articles.each do |article|
      reason = nil

      if [article.CP_WIDTH, article.CP_LENGTH, article.CP_HEIGHT, article.UL_WIDTH_GROSS, article.UL_LENGTH_GROSS, article.UL_HEIGHT_GROSS].all?(&:nil?)
        reason = "Missing dimensions"
      end

      if reason
        Rails.logger.debug "[BinPositioner] Skipping Article #{article.ARTNO}: #{reason}"
        @skipped_articles << { artno: article.ARTNO, reason: reason }
        next
      end

      Rails.logger.debug "[BinPositioner] Trying Article #{article.ARTNO}"
      assigned = false

      article_length = article.CP_LENGTH.to_i.nonzero? || article.UL_LENGTH_GROSS.to_i
      tall_article = article_length >= TALL_ARTICLE_THRESHOLD

      @sections.each do |section|
        next if tall_article && section.sec_depth.to_i < SHALLOW_DEPTH_CUTOFF

        ensure_fixed_levels(section)
        levels = section.levels.where(level_num: MAX_LEVELS)

        if requires_ground_level?(article)
          levels = levels.select { |lvl| lvl.level_num == "00" }
        elsif article.MPQ.to_i != article.PALQ.to_i && article.WEIGHT_G.to_i < 20412
          levels = levels.select { |lvl| %w[01 02].include?(lvl.level_num) }
          levels = levels.sort_by do |lvl|
            lvl.level_num == "01" ? -article.WEIGHT_G.to_i : article.WEIGHT_G.to_i
          end
        else
          levels = levels.sort_by { |lvl| lvl.level_num }
        end

        levels.each do |level|
          if can_assign?(article, section, level)
            article.levels << level unless article.levels.include?(level)
            article.update!(planned: true)
            key = "#{section.id}-#{level.id}"
            used_width = article.CP_WIDTH.to_i.nonzero? || article.UL_WIDTH_GROSS.to_i
            @used_width_by_section_level[key] += used_width

            level_height = if requires_ground_level?(article)
              article.UL_HEIGHT_GROSS.to_i.nonzero?
            else
              (article.CP_HEIGHT.to_i.nonzero? || 0) * (article.RSSQ.to_i.nonzero? || 1)
            end

            if level_height && level_height > 0
              level_height += HEIGHT_TOLERANCE
              if level.level_height.nil? || level.level_height < level_height
                level.update!(level_height: level_height)
                Rails.logger.debug "[BinPositioner] Set Level #{level.level_num} height to #{level_height}"
              end
            end

            Rails.logger.debug "[BinPositioner] Assigned Article #{article.ARTNO} to Section #{section.sectionnum}, Level #{level.level_num}"
            assigned = true
            break
          else
            Rails.logger.debug "[BinPositioner] Article #{article.ARTNO} doesn't fit in Section #{section.sectionnum}, Level #{level.level_num} (Used: #{@used_width_by_section_level["#{section.id}-#{level.id}" ]}, Article Width: #{article.CP_WIDTH})"
          end
        end

        break if assigned
      end

      unless assigned
        width = article.CP_WIDTH.to_i.nonzero? || article.UL_WIDTH_GROSS.to_i
        if width.zero?
          reason = "Missing or zero width"
        elsif width > WIDTH_LIMIT
          reason = "Article width exceeds section limit"
        else
          reason = "Could not be assigned to any section"
        end
        Rails.logger.debug "[BinPositioner] Article #{article.ARTNO} could not be assigned: #{reason}"
        @skipped_articles << { artno: article.ARTNO, reason: reason }
      end
    end
  end

  def export_assignments_to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["ARTNO", "ARTNAME_UNICODE", "SLID_H", "Section", "Level", "Level Height"]
      @aisle.sections.includes(levels: :articles).each do |section|
        section.levels.each do |level|
          level.articles.each do |article|
            csv << [
              article.ARTNO,
              article.ARTNAME_UNICODE,
              article.SLID_H,
              section.sectionnum,
              level.level_num,
              level.level_height
            ]
          end
        end
      end
    end
  end

  private

  def requires_ground_level?(article)
    article.MPQ.to_i == article.PQ.to_i || article.WEIGHT_G.to_i > 20412
  end

  def can_assign?(article, section, level)
    article_depth = article.CP_LENGTH.to_i.nonzero? || article.UL_LENGTH_GROSS.to_i
    section_depth = section.sec_depth.to_i
    article_width = article.CP_WIDTH.to_i.nonzero? || article.UL_WIDTH_GROSS.to_i

    return false if article_depth.zero? || article_width.zero?
    return false if article_depth > section_depth

    (article_width + @used_width_by_section_level["#{section.id}-#{level.id}"]) <= WIDTH_LIMIT
  end

  def ensure_fixed_levels(section)
    existing_levels = section.levels.pluck(:level_num)
    (MAX_LEVELS - existing_levels).each do |lvl_num|
      section.levels.create!(level_num: lvl_num, level_depth: section.sec_depth)
    end
  end
end
