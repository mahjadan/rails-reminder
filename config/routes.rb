Rails.application.routes.draw do
  devise_for :users
  resources :reminders, except: :show

    post 'notifications/:id/complete'  => 'notifications#complete', as: :complete_notification
    post 'notifications/:id/update_snooze' => 'notifications#update_snooze', as: :update_snooze_notification
    get 'notifications/:id/snooze' => 'notifications#snooze', as: :snooze_notification

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "reminders#index"
end
