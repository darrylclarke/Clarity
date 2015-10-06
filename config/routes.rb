Rails.application.routes.draw do
  resources :folders, only: [:show]
  
  # resources :impl_calls
  # resources :preprocessor_lines
  # resources :variables
  resources :code_methods
  # resources :structures
  resources :code_classes, path: "classes"
  resources :code_files
  
  resources :projects do
    resources :display_boxes, only: [:index]
    resources :display_box_links, only: [:index]
  end
  
  resources :users
  
  root "projects#index"
  
end
