Rails.application.routes.draw do
  resources :customer_orders
  devise_for :users
  mount LetterOpenerWeb::Engine, at: "/letters" if Rails.env.development?
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  get "track/:token", to: "tracking#show", as: :tracking

  namespace :admin do
  resources :orders, only: [:index, :update]
  resources :anomalies, only: [:index, :update] do
    collection { post :scan }
  end
end

 root "customer_orders#index"
end
