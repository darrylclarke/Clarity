class FoldersController < ApplicationController

	def show
		@folder = Folder.find_by_id params[:id]
	end
	
end
