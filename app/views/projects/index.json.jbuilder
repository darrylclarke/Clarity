json.array!(@projects) do |project|
  json.extract! project, :id, :name, :root_path
  json.url project_url(project, format: :json)
end
