class BinPositionerService
  def initialize(aisle, filters = {})
    @aisle = aisle
    @filters = filters
    @articles = Article.where(store_id: aisle.store_id, planned: [false, nil])
                       .where(DT: ['0', '1'])
    @articles = @articles.where(HFB: filters[:hfb]) if filters[:hfb].present?
    @articles = @articles.where(PA: filters[:pa]) if filters[:pa].present?
    @sections = aisle.sections.includes(:levels)
  end

  def call
    clean_stale_assignments

    articles = @articles.select { |a| valid_dimensions?(a) }

    @sections.each do |section|
      width_used_by_level = Hash.new(0)
      max_height_by_level = Hash.new(0)

      articles.sort_by { |a| -article_weight(a) }.each do |article|
        next if article.planned?

        width = article_width(article)
        weight = article_weight(article)
        depth = article_depth(article)
        height = article_height(article)
        level_num = determine_level(article, weight)

        next if level_num == "00" && article.UL_LENGTH_GROSS.to_i > section.sec_depth.to_i
        next if level_num != "00" && article.CP_LENGTH.to_i > section.sec_depth.to_i

        level = section.levels.find_or_create_by!(level_num: level_num) do |lvl|
          lvl.level_depth = section.sec_depth
          lvl.level_height = 0
        end

        max_width = section.sec_width.to_i
        next if width_used_by_level[level_num] + width > max_width

        level.articles << article unless level.articles.include?(article)
        article.update!(planned: true)
        width_used_by_level[level_num] += width

        adjusted_height = height
        if level_num != "00" && height > 610
          adjusted_height = ((height.to_f / 2).ceil + 254).to_i
        end

        max_height_by_level[level_num] = [max_height_by_level[level_num], adjusted_height].max
        level.update!(level_height: max_height_by_level[level_num])
      end
    end
  end

  private

  def clean_stale_assignments
    @sections.each do |section|
      section.levels.each do |level|
        level.articles.each do |article|
          level.articles.destroy(article)
          article.update!(planned: false)
        end
      end
    end
  end

  def determine_level(article, weight)
    return "00" if article.DT.to_s == "1" ||
                   (article.DT.to_s == "0" && weight > 22226) ||
                   (article.PALQ.to_i - article.MPQ.to_i < 2)

    return "01" if weight < 22226 && weight < 18144 && weight < 6803.89
    "02"
  end

  def valid_dimensions?(article)
    article_width(article) > 0 && article_depth(article) > 0
  end

  def article_width(article)
    article.DT.to_s == '1' ? article.UL_WIDTH_GROSS.to_i : article.CP_WIDTH.to_i
  end

  def article_depth(article)
    article.DT.to_s == '1' ? article.UL_LENGTH_GROSS.to_i : article.CP_LENGTH.to_i
  end

  def article_weight(article)
    article.WEIGHT_G.to_i
  end

  def article_height(article)
    if article.DT.to_s == '1'
      article.UL_HEIGHT_GROSS.to_i + 254
    else
      (article.CP_HEIGHT.to_i * article.RSSQ.to_i) + 254
    end
  end
end