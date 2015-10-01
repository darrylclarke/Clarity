json.array!(@code_methods) do |code_method|
  json.extract! code_method, :id, :name, :return_type, :arguments, :code_file_id, :code_class_id, :impl_start, :impl_end
  json.url code_method_url(code_method, format: :json)
end
