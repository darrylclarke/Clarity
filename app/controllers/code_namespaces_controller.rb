class CodeNamespacesController < ApplicationController
	def index
		@code_namespaces = CodeNamespace.all
	end
	
	def show
		@code_namespace = CodeNamespace.find params[:id]
		@classes   = CodeClass.by_project_and_namespace(  current_project_id, @code_namespace.id )
		@methods   = CodeMethod.by_project_and_namespace( current_project_id, @code_namespace.id )
		@variables = Variable.by_project_and_namespace(   current_project_id, @code_namespace.id )
	end
end
