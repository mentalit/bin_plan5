require 'csv'

class ArticleUploadService
  def initialize(files:, store_id:, filters: {})
    @files = Array(files)
    @store_id = store_id
    @filters = filters
  end

  def call
    @files.each do |file|
      cleaned_data = File.read(file.path).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      CSV.parse(cleaned_data, headers: true) do |row|
        article_hash = build_article_hash(row)
        next unless article_hash[:ARTNO].present?
        next unless passes_filters?(article_hash)

        article = Article.find_or_initialize_by(ARTNO: article_hash[:ARTNO], store_id: @store_id)
        article.assign_attributes(article_hash.compact.merge(store_id: @store_id))
        article.planned = false if article.planned.nil?
        article.save!
      end
    end
  end

  def export_assignments_to_csv(articles)
    CSV.generate(headers: true) do |csv|
      csv << %w[ARTNO ARTNAME_UNICODE SECTION LEVEL]

      articles.each do |article|
        article.levels.each do |level|
          csv << [
            article.ARTNO,
            article.ARTNAME_UNICODE,
            article.UL_WIDTH_GROSS,
            article.CP_WIDTH,
            level.section.sectionnum,
            level.level_num
          ]
        end
      end
    end
  end

  private

  def build_article_hash(row)
    {
      ARTNO: row['ARTNO'] || row['Item No'],
      HFB: row['HFB'],
      PA: row['PA'],
      ARTNAME_UNICODE: sanitize_text(row['ARTNAME_UNICODE']),
      CP_LENGTH: row['CP_LENGTH'],
      CP_WIDTH: row['CP_WIDTH'],
      CP_HEIGHT: row['CP_HEIGHT'],
      WEIGHT_G: row['WEIGHT_G'],
      SLID_H: row['SLID_H'],
      MPQ: row['MPQ'],
      PALQ: row['PALQ'],
      SSD: row['SSD'],
      EDS: parse_date(row['EDS']),
      DTFP: row['DTFP'],
      DTFP_PLUS: row['DTFP_PLUS'],
      RSSQ: row['RSSQ'],
      SALESMETHOD: normalize_sm(row['SALESMETHOD']),
      DT: row['DT'],
      UL_LENGTH_GROSS: row['UL Length Gross'] || row['UL_LENGTH_GROSS'],
      UL_WIDTH_GROSS:  row['UL Width Gross']  || row['UL_WIDTH_GROSS'],
      UL_HEIGHT_GROSS: row['UL Height Gross'] || row['UL_HEIGHT_GROSS']
    }
  end

  def sanitize_text(text)
    text.to_s.strip.presence
  end

  def parse_date(value)
    return if value.blank?
    Date.parse(value) rescue nil
  end

  def normalize_sm(sm)
    sm.to_s.strip
  end

  def passes_filters?(article_hash)
    return true if @filters[:upload_all]
    return false if @filters[:hfb].present? && article_hash[:HFB] != @filters[:hfb]
    return false if @filters[:pa].present? && article_hash[:PA] != @filters[:pa]
    return false if @filters[:sm_list].present? && !@filters[:sm_list].include?(article_hash[:SALESMETHOD])
    return false if @filters[:ssd_cutoff].present? && article_hash[:SSD].to_i > @filters[:ssd_cutoff].to_i

    if @filters[:eds_baseonhand_date].present?
      eds = article_hash[:EDS].to_s.gsub(/[^\d]/, '').to_i
      limit = @filters[:eds_baseonhand_date].to_s.gsub(/[^\d]/, '').to_i
      return false unless eds < limit && article_hash[:BASEONHAND].to_i > 0
    end

    true
  end
end
