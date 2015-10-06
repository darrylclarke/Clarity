class DisplayBoxesController < ApplicationController

	def index
		@project = Project.find params[:project_id]
		@display_boxes = DisplayBox.where(project_id: @project.id).order(:display_id)
		
		respond_to do |format|
			format.json { render json: @display_boxes }
			format.html { redirect_to root_path }
		end				
	
	end
end
