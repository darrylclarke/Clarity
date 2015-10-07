class FoldersController < ApplicationController

	def show
		@folder = Folder.find_by_id params[:id]
		@project = Project.find @folder.project_id
	end
	
end
