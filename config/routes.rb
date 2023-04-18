Rails.application.routes.draw do
  devise_for :users
  resources :reminders do
    member {
      post  'complete'
      post 'snooze'
     }
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "reminders#index"
end
