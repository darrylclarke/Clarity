json.array!(@code_files) do |code_file|
  json.extract! code_file, :id, :name, :path, :project_id
  json.url code_file_url(code_file, format: :json)
end
