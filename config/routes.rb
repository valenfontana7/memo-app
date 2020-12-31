Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#health'
  get '/tasks', to: 'posts#published_tasks'
  get '/public/tasks', to: 'posts#published_public_tasks'
  get '/tasks/:id', to: 'posts#task'
  post '/posts', to: 'posts#create'
  put '/posts/:id', to: 'posts#update'
end
