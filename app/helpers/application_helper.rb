module ApplicationHelper

	def current_project_name
		project_id = current_project_id
		if project_id
			project = Project.find_by_id( project_id )
		end
		if project
			project.name
		else
			""
		end
	end
end
