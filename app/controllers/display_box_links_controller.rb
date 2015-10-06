class DisplayBoxLinksController < ApplicationController
	def index
		@project = Project.find params[:project_id]
		@display_box_links = DisplayBoxLink.where(project_id: @project.id)
		
		respond_to do |format|
			format.json { render json: @display_box_links }
			format.html { redirect_to root_path }
		end				
	
	end
end

