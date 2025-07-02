class BinPositionerService
  def initialize(aisle, filters = {})
    @aisle = aisle
    @filters = filters
    @articles = Article.where(store_id: aisle.store_id, planned: [false, nil])
                        .where(DT: ['0', '1'])
                        .where('("DT" = ? AND "WEIGHT_G" > ?) OR "DT" = ?', '0', 22226, '1')
    @articles = @articles.where(HFB: filters[:hfb]) if filters[:hfb].present?
    @articles = @articles.where(PA: filters[:pa]) if filters[:pa].present?
    @sections = aisle.sections.includes(:levels)
  end

  def call
    clean_stale_assignments

    articles = @articles.select { |a| valid_dimensions?(a) }

    @sections.each do |section|
      next if section.sec_depth.to_i < 1296

      level = section.levels.find_by(level_num: '00')
      next unless level

      max_width = section.sec_width.to_i
      width_used = 0
      tallest_height = 0

      # Sort articles greedily by width descending
      articles.sort_by { |a| -article_width(a) }.each do |article|
        next if article.planned?

        width = article_width(article)
        depth = article_depth(article)
        height = article_height(article)
        location_type = @aisle.loc_type

        Rails.logger.debug "🟡 Checking \#{article.ARTNO} — width: \#{width}, depth: \#{depth}, height: \#{height}, aisle type: \#{location_type}"

        if width <= 0
          Rails.logger.debug "⛔ Skipping \#{article.ARTNO} due to invalid or missing width"
          next
        end

        if depth <= 0
          Rails.logger.debug "⛔ Skipping \#{article.ARTNO} due to invalid or missing depth"
          next
        end

        if width_used + width > max_width
          Rails.logger.debug "⛔ Skipping \#{article.ARTNO} due to width overflow (used: \#{width_used}, article: \#{width}, max: \#{max_width})"
          next
        end

        Rails.logger.debug "✅ Assigning \#{article.ARTNO} (DT=\#{article.DT}) to section \#{section.sectionnum} level 00"
        level.articles << article unless level.articles.include?(article)
        article.update!(planned: true)
        width_used += width

        tallest_height = [tallest_height, height].max
      end

      if tallest_height > 0
        level.update!(level_height: tallest_height)
      end
    end
  end

  private

  def clean_stale_assignments
    @sections.each do |section|
      level = section.levels.find_by(level_num: '00')
      next unless level

      level.articles.each do |article|
        if article.DT.to_s == '1' || (article.DT.to_s == '0' && article.WEIGHT_G.to_i > 22226)
          Rails.logger.debug "🧹 Removing stale assignment: \#{article.ARTNO} from section \#{section.sectionnum}"
          level.articles.destroy(article)
          article.update!(planned: false)
        end
      end
    end
  end

  def valid_dimensions?(article)
    width = article_width(article)
    depth = article_depth(article)
    width > 0 && depth > 0
  end

  def article_width(article)
    article.DT.to_s == '1' ? article.UL_WIDTH_GROSS.to_i : article.CP_WIDTH.to_i
  end

  def article_depth(article)
    article.DT.to_s == '1' ? article.UL_LENGTH_GROSS.to_i : article.CP_LENGTH.to_i
  end

  def group_by_height(articles)
    tolerance = 254
    groups = {}

    articles.each do |article|
      height = article_height(article)
      key = groups.keys.find { |h| (h - height).abs <= tolerance } || height
      groups[key] ||= []
      groups[key] << article
    end

    groups
  end

  def article_height(article)
    if article.DT.to_s == '1'
      article.UL_HEIGHT_GROSS.to_i + 254
    else
      (article.CP_HEIGHT.to_i * article.RSSQ.to_i) + 254
    end
  end
end
