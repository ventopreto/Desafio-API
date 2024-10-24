Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "/movie", to: "movie#create"
    end
  end
end
