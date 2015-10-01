class CodeMethodsController < ApplicationController
  before_action :set_code_method, only: [:show, :edit, :update, :destroy]

  # GET /code_methods
  # GET /code_methods.json
  def index
    @code_methods = CodeMethod.all
  end

  # GET /code_methods/1
  # GET /code_methods/1.json
  def show
  end

  # GET /code_methods/new
  def new
    @code_method = CodeMethod.new
  end

  # GET /code_methods/1/edit
  def edit
  end

  # POST /code_methods
  # POST /code_methods.json
  def create
    @code_method = CodeMethod.new(code_method_params)

    respond_to do |format|
      if @code_method.save
        format.html { redirect_to @code_method, notice: 'Code method was successfully created.' }
        format.json { render :show, status: :created, location: @code_method }
      else
        format.html { render :new }
        format.json { render json: @code_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_methods/1
  # PATCH/PUT /code_methods/1.json
  def update
    respond_to do |format|
      if @code_method.update(code_method_params)
        format.html { redirect_to @code_method, notice: 'Code method was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_method }
      else
        format.html { render :edit }
        format.json { render json: @code_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_methods/1
  # DELETE /code_methods/1.json
  def destroy
    @code_method.destroy
    respond_to do |format|
      format.html { redirect_to code_methods_url, notice: 'Code method was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_method
      @code_method = CodeMethod.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_method_params
      params.require(:code_method).permit(:name, :type, :arguments, :code_file_id, :code_class_id, :impl_start, :impl_end)
    end
end
