Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # ΘΕΜΑ 1: Λειτουργίες Portal
  scope :portal do
    resources :posts
    resources :messages do
      collection do
        get :groups
        get :chat
      end
    end
    # Δεν χρειαζόμαστε edit/update για τα contacts, άρα τα περιορίζουμε
    resources :contacts, only: [:index, :create, :destroy]
    resources :notifications, only: [:index] do
      member do
        patch :mark_read
      end
    end
  end

  # ΘΕΜΑ 2: REST API για Todo List
  scope module: "api/v1", defaults: { format: :json } do
    post "/signup", to: "auth#signup"
    post "/auth/login", to: "auth#login"
    get "/auth/logout", to: "auth#logout"

    get "/todos", to: "todos#index"
    post "/todos", to: "todos#create"
    get "/todos/:id", to: "todos#show"
    put "/todos/:id", to: "todos#update"
    delete "/todos/:id", to: "todos#destroy"

    get "/todos/:id/items/:iid", to: "todo_items#show"
    post "/todos/:id/items", to: "todo_items#create"
    put "/todos/:id/items/:iid", to: "todo_items#update"
    delete "/todos/:id/items/:iid", to: "todo_items#destroy"
  end
  get "up" => "rails/health#show", as: :rails_health_check
  root "posts#index"
end
