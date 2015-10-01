class CodeFilesController < ApplicationController
  before_action :set_code_file, only: [:show, :edit, :update, :destroy]

  # GET /code_files
  # GET /code_files.json
  def index
    @code_files = CodeFile.all
  end

  # GET /code_files/1
  # GET /code_files/1.json
  def show
  end

  # GET /code_files/new
  def new
    @code_file = CodeFile.new
  end

  # GET /code_files/1/edit
  def edit
  end

  # POST /code_files
  # POST /code_files.json
  def create
    @code_file = CodeFile.new(code_file_params)

    respond_to do |format|
      if @code_file.save
        format.html { redirect_to @code_file, notice: 'Code file was successfully created.' }
        format.json { render :show, status: :created, location: @code_file }
      else
        format.html { render :new }
        format.json { render json: @code_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_files/1
  # PATCH/PUT /code_files/1.json
  def update
    respond_to do |format|
      if @code_file.update(code_file_params)
        format.html { redirect_to @code_file, notice: 'Code file was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_file }
      else
        format.html { render :edit }
        format.json { render json: @code_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_files/1
  # DELETE /code_files/1.json
  def destroy
    @code_file.destroy
    respond_to do |format|
      format.html { redirect_to code_files_url, notice: 'Code file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_file
      @code_file = CodeFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_file_params
      params.require(:code_file).permit(:name, :path, :project_id)
    end
end
