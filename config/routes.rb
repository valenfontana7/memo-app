Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#health'
  # Users
  get '/users', to: 'users#users'
  # Auth
  post '/signup', to: 'users#create'
  post '/login', to: 'users#login'
  # Tasks
  get '/tasks', to: 'posts#published_tasks'
  get '/tasks/drafts', to: 'posts#draft_tasks'
  get '/public/tasks', to: 'posts#published_public_tasks'
  get '/tasks/:id', to: 'posts#published_task'
  # Links
  get '/links', to: 'posts#published_links'
  get '/links/drafts', to: 'posts#draft_links'
  get '/public/links', to: 'posts#published_public_links'
  get '/links/:id', to: 'posts#published_link'
  # Articles
  get '/articles', to: 'posts#published_articles'
  get '/articles/drafts', to: 'posts#draft_articles'
  get '/public/articles', to: 'posts#published_public_articles'
  get '/articles/:id', to: 'posts#published_article'
  # Notes
  get '/notes', to: 'posts#published_notes'
  get '/notes/drafts', to: 'posts#draft_notes'
  get '/public/notes', to: 'posts#published_public_notes'
  get '/notes/:id', to: 'posts#published_note'
  # General Posts
  post '/posts', to: 'posts#create'
  put '/posts/:id', to: 'posts#update'
  put '/posts/:id/addowner/:uid', to: 'posts#addowner'
  put '/posts/:id/delowner/:uid', to: 'posts#delowner'
end
