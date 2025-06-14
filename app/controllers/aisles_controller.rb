class AislesController < ApplicationController
  before_action :get_store, only: %i[ new create index]
  before_action :set_aisle, only: %i[ show edit update destroy ]

  # GET /aisles or /aisles.json
  def index
    @aisles = @store.aisles
  end

  # GET /aisles/1 or /aisles/1.json
  def show
  end

  # GET /aisles/new
  def new
    @aisle = @store.aisles.build
  end

  # GET /aisles/1/edit
  def edit
  end

  # POST /aisles or /aisles.json
  def create
    @aisle = @store.aisles.build(aisle_params)

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

  # DELETE /aisles/1 or /aisles/1.json
  def destroy
    @aisle.destroy!

    respond_to do |format|
      format.html { redirect_to aisles_path, status: :see_other, notice: "Aisle was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aisle
      @aisle = Aisle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def aisle_params
      params.require(:aisle).permit(:aislenum, :aislestart, :aisleend, :aisledepth, :aisleheight, :store_id)
    end
end
