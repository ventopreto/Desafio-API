class MovieImportSerializer
  include Alba::Resource

  attributes :id, :file_name, :error_message, :status, :movies_count
end
