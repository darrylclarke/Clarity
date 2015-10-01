Rails.application.routes.draw do
  resources :impl_calls
  resources :preprocessor_lines
  resources :variables
  resources :code_methods
  resources :structures
  resources :code_classes, path: "classes"
  resources :code_files
  resources :projects
  resources :users
  
  root "welcome#index"
  
end
