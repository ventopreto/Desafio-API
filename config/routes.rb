Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "/movies", to: "movies#create"
      get "/movies", to: "movies#index"
    end
  end
end
