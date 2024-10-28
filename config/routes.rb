Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      post "/movies", to: "movies#create"
      get "/movies", to: "movies#index"
    end
  end
end
