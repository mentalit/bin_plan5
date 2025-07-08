class AislesController < ApplicationController
  before_action :get_store, only: %i[ new create index ]
  before_action :set_aisle, only: %i[ show edit update destroy plan_articles export_assignments ]

  # GET /aisles or /aisles.json
  def index
    @aisles = @store.aisles
  end

  # GET /aisles/1 or /aisles/1.json
  def show
     @store = @aisle.store
    @sections = @aisle.sections.includes(levels: :articles)
    all_articles = Article.where(store_id: @aisle.store_id, planned: true)
  relevant_articles = all_articles.select do |a|
    a.DT.to_s == "1" || (a.DT.to_s == "0" && a.WEIGHT_G.to_i > 22226)
  end

  max_height = relevant_articles.map(&:UL_HEIGHT_GROSS).compact.map(&:to_i).max || 0
  @level_height = max_height + 254
  end

  # GET /aisles/new
  def new
    @aisle = @store.aisles.build
  end

  # GET /aisles/1/edit
  def edit
  end

  def clear_planned_articles
  aisle = Aisle.find(params[:id])

  # Unassign all DT=1 articles from level 00 in the aisle's sections
  aisle.sections.includes(:levels).each do |section|
    level = section.levels.find_by(level_num: '00')
    next unless level

    level.articles.each do |article|
      if article.DT.to_s == '1'
        level.articles.destroy(article)
        article.update!(planned: false)
      end
    end
  end

  redirect_to aisle_path(aisle), notice: "Planned DT=1 articles cleared."
end

  def destroy_nonzero_levels
  @aisle = Aisle.find(params[:id])
  @aisle.sections.includes(:levels).each do |section|
    section.levels.where.not(level_num: "00").destroy_all
  end
  redirect_to aisle_path(@aisle), notice: "All non-00 levels were deleted."
end

  def plan_articles
    @planner = BinPositionerService.new(@aisle, hfb: params[:hfb], pa: params[:pa])
    @planner.call
    @multi_location_tracker = @planner.instance_variable_get(:@multi_location_tracker)
    redirect_to aisle_path(@aisle), notice: "Articles planned"
  end

 def export_assignments
  aisle = Aisle.find(params[:id])
  articles = aisle.sections.flat_map { |s| s.levels.flat_map(&:articles) }.uniq

  csv_data = ArticleUploadService.new(files: [], store_id: aisle.store_id).export_assignments_to_csv(articles)

  send_data csv_data, filename: "aisle_#{aisle.aislenum}_assignments.csv"
end


  # POST /aisles or /aisles.json
  def create
    @aisle = @store.aisles.build(aisle_params)
    sec_width = params[:aisle][:sec_width].to_i

    respond_to do |format|
      if @aisle.save
        format.html { redirect_to @aisle, notice: "Aisle was successfully created." }
        format.json { render :show, status: :created, location: @aisle }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aisle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aisles/1 or /aisles/1.json
  def update
    respond_to do |format|
      if @aisle.update(aisle_params)
        format.html { redirect_to @aisle, notice: "Aisle was successfully updated." }
        format.json { render :show, status: :ok, location: @aisle }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aisle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aisles/1 or /aisles.json
  def destroy
    @aisle.destroy!

    respond_to do |format|
      format.html { redirect_to aisles_path, status: :see_other, notice: "Aisle was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_aisle
    @aisle = Aisle.find(params[:id])
  end

  def aisle_params
    params.require(:aisle).permit(:aislenum, :aislestart, :aisleend, :aisledepth, :aisleheight, :loc_type, :store_id)
  end

  def get_store
    @store = Store.find(params[:store_id])
  end
end