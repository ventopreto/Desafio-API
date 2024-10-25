Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "/movies", to: "movies#create"
    end
  end
end
