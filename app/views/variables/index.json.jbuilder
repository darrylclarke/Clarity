json.array!(@variables) do |variable|
  json.extract! variable, :id, :name, :type, :code_file_id, :code_class_id, :line
  json.url variable_url(variable, format: :json)
end
