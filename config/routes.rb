Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#health'
  get '/tasks', to: 'posts#published_tasks'
  get '/tasks/drafts', to: 'posts#draft_tasks'
  get '/tasks/drafts/:id', to: 'posts#draft_task'
  get '/public/tasks', to: 'posts#published_public_tasks'
  get '/public/tasks/:id', to: 'posts#published_public_task'
  get '/tasks/:id', to: 'posts#published_task'
  post '/posts', to: 'posts#create'
  put '/posts/:id', to: 'posts#update'
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
end
