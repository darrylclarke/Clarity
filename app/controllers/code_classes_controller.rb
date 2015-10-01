class CodeClassesController < ApplicationController
  before_action :set_code_class, only: [:show, :edit, :update, :destroy]

  # GET /code_classes
  # GET /code_classes.json
  def index
    @code_classes = CodeClass.all
  end

  # GET /code_classes/1
  # GET /code_classes/1.json
  def show
  end

  # GET /code_classes/new
  def new
    @code_class = CodeClass.new
  end

  # GET /code_classes/1/edit
  def edit
  end

  # POST /code_classes
  # POST /code_classes.json
  def create
    @code_class = CodeClass.new(code_class_params)

    respond_to do |format|
      if @code_class.save
        format.html { redirect_to @code_class, notice: 'Code class was successfully created.' }
        format.json { render :show, status: :created, location: @code_class }
      else
        format.html { render :new }
        format.json { render json: @code_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_classes/1
  # PATCH/PUT /code_classes/1.json
  def update
    respond_to do |format|
      if @code_class.update(code_class_params)
        format.html { redirect_to @code_class, notice: 'Code class was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_class }
      else
        format.html { render :edit }
        format.json { render json: @code_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_classes/1
  # DELETE /code_classes/1.json
  def destroy
    @code_class.destroy
    respond_to do |format|
      format.html { redirect_to code_classes_url, notice: 'Code class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_class
      @code_class = CodeClass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_class_params
      params.require(:code_class).permit(:name, :ancestors, :code_file_id, :line)
    end
end
