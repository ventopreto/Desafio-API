Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      post "/movies", to: "movies#create"
      get "/movies", to: "movies#index"
      get "/movie_imports/:id", to: "movie_imports#show"
    end
  end
end
