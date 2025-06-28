class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :get_store, only: %i[index new create import_form import]

  def index
    @articles = @store.articles
  end

  def show; end

  def new
    @article = @store.articles.build
  end

  def create
    @article = @store.articles.build(article_params)
    @article.planned = false
    if @article.save
      redirect_to @article, notice: "Article was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy!
    redirect_to store_articles_path(@article.store), status: :see_other, notice: "Article was successfully destroyed."
  end

  def import_form
    respond_to do |format|
      format.html
    end
  end

  def import
    if params[:files].present?
      files = params[:files].is_a?(Array) ? params[:files] : [params[:files]]

      ArticleUploadService.new(
        files: files,
        store_id: @store.id,
        filters: extract_filters
      ).call

      redirect_to store_articles_path(@store), notice: "Articles imported."
    else
      redirect_to store_articles_path(@store), alert: "Please upload at least one CSV file."
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def get_store
    @store = Store.find(params[:store_id])
  end

  def extract_filters
    {
      hfb: params[:hfb],
      pa: params[:pa],
      sm_list: params[:sm_list].to_s.split(",").map(&:strip),
      ssd_cutoff: params[:ssd_cutoff].presence,
      eds_baseonhand_date: params[:eds_baseonhand_date].presence,
      upload_all: params[:upload_all] == "1"
    }
  end

  def article_params
  params.require(:article).permit(
    :ARTNO, :ARTNAME_UNICODE, :SALESMETHOD, :RANGECODE1,
    :LENGTH_M, :WIDTH_M, :HEIGHT_M, :VOLUME_M3, :WEIGHT_G,
    :SLID_H, :MPQ, :PALQ, :SSD, :EDS, :DTFP, :DTFP_PLUS,
    :RSSQ, :SAL_SOL_INDIC, :UL_HEIGHT_GROSS, :UL_LENGTH_GROSS,
    :UL_WIDTH_GROSS, :UL_DIAMTER, :CP_HEIGHT, :CP_LENGTH,
    :CP_WIDTH, :HFB, :PA, :SM, :BASEONHAND, :planned
    )
  end
end