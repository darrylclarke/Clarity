json.array!(@code_classes) do |code_class|
  json.extract! code_class, :id, :name, :ancestors, :code_file_id, :line
  json.url code_class_url(code_class, format: :json)
end
