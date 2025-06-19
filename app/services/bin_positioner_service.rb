class BinPositionerService
  require 'csv'

  WIDTH_LIMIT = 2921 # max width per section
  HEIGHT_TOLERANCE = 254
  MAX_LEVELS = %w[00 01 02]
  SHALLOW_DEPTH_CUTOFF = 1524
  TALL_ARTICLE_THRESHOLD = 2000
  HEIGHT_GROUP_TOLERANCE = 100

  attr_reader :skipped_articles

  def initialize(aisle, filters = {})
    @aisle = aisle
    @filters = filters
    @articles = Article.where(store_id: aisle.store_id, planned: [false, nil])
    @articles = @articles.where('"HFB" = ?', filters[:hfb]) if filters[:hfb].present?
    @articles = @articles.where('"PA" = ?', filters[:pa]) if filters[:pa].present?
    @sections = aisle.sections.includes(:levels)
    @used_width_by_section_level = Hash.new(0)
    @max_height_by_section_level = Hash.new(0)
    @skipped_articles = []
    @multi_location_tracker = Hash.new(0)
  end

  def call
    Rails.logger.debug "[BinPositioner] Starting for Aisle ##{@aisle.id}"

    @articles.each do |article|
      reason = nil

      width = select_width(article)
      length = select_length(article)
      if width.nil? || width.zero?
        reason = "Missing or invalid width"
        Rails.logger.debug "[BinPositioner] Skipping Article #{article.ARTNO}: #{reason}"
        @skipped_articles << { artno: article.ARTNO, reason: reason }
        next
      end

      level_num = select_level(article)

      @sections.each do |section|
        # New rule: skip section if DT = 1 and UL_LENGTH > 1296 and section depth < 1296
        if article.DT.to_s == "1" && article.UL_LENGTH_GROSS.to_i > 1296 && section.sec_depth < 1296
          Rails.logger.debug "[BinPositioner] Skipping Section #{section.sectionnum} for Article #{article.ARTNO} due to DT=1 UL_LENGTH constraint"
          next
        end

        # Exclude article from section based on length mismatch
        if (length < 1296 && section.sec_depth > 1324) || (length > 1296 && section.sec_depth < 1324)
          Rails.logger.debug "[BinPositioner] Skipping Section #{section.sectionnum} for Article #{article.ARTNO} due to length mismatch"
          next
        end

        ensure_fixed_levels(section)
        level = section.levels.find_by(level_num: level_num)
        next unless level

        key = "#{section.id}-#{level.id}"
        if @used_width_by_section_level[key] + width <= WIDTH_LIMIT
          article.levels << level unless article.levels.include?(level)
          @used_width_by_section_level[key] += width

          article_height = article.CP_HEIGHT.to_i.nonzero? || article.UL_HEIGHT_GROSS.to_i
          if article_height > 0 && article_height > @max_height_by_section_level[key]
            @max_height_by_section_level[key] = article_height
            if level.level_num == "00"
              level.update!(level_height: article_height + HEIGHT_TOLERANCE)
            end
          end

          article.update!(planned: true)
          @multi_location_tracker[article.id] += 1

          Rails.logger.debug "[BinPositioner] Assigned Article #{article.ARTNO} to Section #{section.sectionnum}, Level #{level.level_num}"
          break
        end
      end
    end
  end

  def export_assignments_to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["ARTNO", "ARTNAME_UNICODE", "SLID_H", "Section", "Level", "Level Height", "Multiple Locations"]
      @aisle.sections.includes(levels: :articles).each do |section|
        section.levels.each do |level|
          level.articles.each do |article|
            csv << [
              article.ARTNO,
              article.ARTNAME_UNICODE,
              article.SLID_H,
              section.sectionnum,
              level.level_num,
              level.level_height,
              @multi_location_tracker[article.id] > 1 ? 'Yes' : 'No'
            ]
          end
        end
      end
    end
  end

  private

  def select_width(article)
    if article.DT.to_s == "1" || article.WEIGHT_G.to_i >= 12192
      article.UL_WIDTH_GROSS.to_i
    else
      article.CP_WIDTH.to_i
    end
  end

  def select_length(article)
    if article.DT.to_s == "1" || article.WEIGHT_G.to_i >= 12192
      article.UL_LENGTH_GROSS.to_i
    else
      article.CP_LENGTH.to_i.nonzero? || article.UL_LENGTH_GROSS.to_i
    end
  end

  def select_level(article)
    if article.DT.to_s == "1" || article.WEIGHT_G.to_i >= 12192
      "00"
    elsif article.WEIGHT_G.to_i < 18143 && article.WEIGHT_G.to_i > 9072
      "01"
    else
      "02"
    end
  end

  def ensure_fixed_levels(section)
    existing_levels = section.levels.pluck(:level_num)
    (MAX_LEVELS - existing_levels).each do |lvl_num|
      section.levels.create!(level_num: lvl_num, level_depth: section.sec_depth)
    end
  end
end
