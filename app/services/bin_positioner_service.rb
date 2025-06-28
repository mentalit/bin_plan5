class BinPositionerService
  def initialize(aisle, filters = {})
    @aisle = aisle
    @filters = filters
    @articles = Article.where(store_id: aisle.store_id, planned: [false, nil])
    @articles = @articles.where(HFB: filters[:hfb]) if filters[:hfb].present?
    @articles = @articles.where(PA: filters[:pa]) if filters[:pa].present?
    @sections = aisle.sections.includes(:levels)
  end

  def call
    articles = @articles.select { |a| valid_dimensions?(a) }
    grouped_articles = group_by_height(articles)

    @sections.each do |section|
      next if section.sec_depth.to_i < 1296

      section_levels = section.levels.index_by(&:level_num)
      max_width = section.sec_width.to_i

      level_00 = section_levels["00"] || section.levels.create!(
        level_num: "00",
        level_depth: section.sec_depth,
        level_height: 0
      )
      width_used = Hash.new(0)

      grouped_articles.sort_by { |h, _| -h }.each do |height, articles|
        articles.sort_by! { |a| -article_width(a) }

        articles.each do |article|
          next if article.planned?

          width = article_width(article)
          next if width <= 0

          level = determine_level(section, section_levels, height, article)
          next unless level

          next if width_used[level.id] + width > max_width

          article.levels << level unless article.levels.include?(level)
          article.update!(planned: true)
          width_used[level.id] += width
          level.update!(level_height: [level.level_height.to_i, height].max)
        end
      end
    end
  end

  private

  def valid_dimensions?(article)
    dt = article.DT.to_s
    return false unless %w[0 1].include?(dt)

    width = article_width(article)
    depth = article_depth(article)
    min_depth_ratio = 0.5

    @sections.any? do |section|
      section_depth = section.sec_depth.to_i
      next if section_depth < 1296

      width > 0 && depth > 0 && depth >= (section_depth * min_depth_ratio)
    end
  end

  def article_width(article)
    (article.DT.to_s == "1" ? article.UL_WIDTH_GROSS : article.CP_WIDTH).to_i rescue 0
  end

  def article_depth(article)
    (article.DT.to_s == "1" ? article.UL_LENGTH_GROSS : article.CP_LENGTH).to_i rescue 0
  end

  def article_height(article)
    if article.DT.to_s == "1"
      article.UL_HEIGHT_GROSS.to_i
    else
      (article.CP_HEIGHT.to_i * article.RSSQ.to_i) + 254
    end
  end

  def group_by_height(articles)
    tolerance = 254
    groups = {}

    articles.each do |article|
      height = article_height(article)
      next if height <= 0

      key = groups.keys.find { |h| (h - height).abs <= tolerance } || height
      groups[key] ||= []
      groups[key] << article
    end

    groups
  end

  def determine_level(section, section_levels, height, article)
    # Only allow level > 00 if level 00 exists and is full
    base_level = section_levels["00"]
    return nil unless base_level

    # Enforce strict creation order: 01 -> 02 -> 03 ...
    (0..9).each do |i|
      level_num = i.to_s.rjust(2, '0')
      existing = section_levels[level_num]

      if existing && existing.level_height.to_i >= height
        return existing
      elsif !existing && (i == 0 || section_levels[(i - 1).to_s.rjust(2, '0')])
        new_level = section.levels.create!(
          level_num: level_num,
          level_depth: section.sec_depth,
          level_height: 0
        )
        section_levels[level_num] = new_level
        return new_level
      end
    end

    nil
  end
end
