class ImportMoviesJob < ApplicationJob
  queue_as :default

  def perform(import_id, path, content_type)
    MovieImport.find(import_id).import_movies(path, content_type)
  ensure
    File.delete(path) if path && File.exist?(path)
  end
end
