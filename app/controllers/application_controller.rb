class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def current_project_id
    session[:current_project_id]
  end
  helper_method :current_project_id
  
  def set_current_project( project )
    value = (project==nil ? nil : project.id)
    session[:current_project_id] = value
  end
    
end
