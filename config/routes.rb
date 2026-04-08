Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")

  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :libraries do
    resources :collections, except: [:index, :edit, :update] do
      resources :assets, except: [:index] do
        resources :comments, only: [:create, :destroy]
        get    :download,    on: :member
        post   :share,       on: :member
        delete :revoke_share, on: :member
        delete :remove_file,  on: :member
      end
    end
  end

  resources :activity_logs, only: [:index]

  # Public share link (no auth required)
  get "/s/:token", to: "shared_assets#show", as: :shared_asset

  namespace :api do
    namespace :v1 do
      resources :collections, only: [] do
        resources :assets, only: [:index]
      end
      resources :assets, only: [:update]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
