# 1) Crear el proyecto con rails new *nombreproyecto* --api -T
# 2) Probar que funcione con rails s
# 3) Agregar las gemas en el Gemfile:
 group :test do  
  gem 'factory_bot_rails', '~> 4.0'  
  gem 'shoulda', '~> 3.6.0'  
  gem 'shoulda-matchers', '~> 3.1.3'  
  gem 'rails-controller-testing', '~> 1.0.4'  
  gem 'faker', '~> 1.9'  
  gem 'database_cleaner', '~> 1.7'  
  gem 'rspec-rails', '~> 3.5'  
 end  
# 4) Correr bundle install
# 5) Ejecutar rails g rspec:install
# 6) Comprobar que funcione con el comando rspec
# 7) Agregar configuracion en spec/rails_helper.rb:
- Add additional requires below this line. Rails is not loaded until this point!

require 'database_cleaner'  
require 'shoulda-matchers'  
require 'factory_bot_rails'  

Shoulda::Matchers.configure do |config|  
   config.integrate do |with|  
  Choose a test framework:  
   with.test_framework :rspec  
  Choose one or more libraries:  
   with.library :active_record  
   with.library :active_model  
   with.library :action_controller  
  Or, choose all of the above:  
   with.library :rails  
  end  
end  
  
RSpec.configure do |config|  
  config.include FactoryBot::Syntax::Methods    
  config.before(:suite) do  
    DatabaseCleaner.strategy = :transaction  
    DatabaseCleaner.clean_with(:truncation)  
  end  
  config.around(:each) do |example|  
    DatabaseCleaner.cleaning do  
      example.run  
  end
  end  
# 8) Configurar servicio de status del endpoint: mkdir spec/requests y touch spec/requests/health_spec.rb
# 9) Dentro de health_spec.rb escribir la prueba
require "rails_helper"  
RSpec.describe "health endpoint", type: :request do  
  describe "GET /health" do  
    before { get '/health' }  
    it "should return OK" do  
      payload = JSON.parse(response.body)  
      expect(payload).not_to be_empty  
      expect(payload['api']).to eq('OK')  
    end  
    it "should return status code 200" do  
      expect(response).to have_http_status(200)  
    end  
  end  
end  
# 10) Ejecutar rails db:migrate y rspec
# 11) Los tests no deberían pasar, hay que hacer que pasen
# 12) Crear dentro de app/controllers un controlador health_controller.rb
class HealthController < ApplicationController  
  def health  
    render json: { api: "OK" }, status: :ok  
  end  
end  
# 13) Agregar la ruta /health en config/routes.rb
Rails.application.routes.draw do  
  get '/health', to: 'health#health'  
end  
# 14) Definir los diagramas de entidad relación (simplificado)

User: {  
  id  
  first_name  
  last_name  
  role: ['user', 'admin']  
  status: ['active', 'inactive']  
  email  
  auth_token  
}  

Post: {  
  id  
  status: ['pending', 'published', 'deleted']  
  core: ['note', 'task', 'article', 'link']  
  title  
  content  
  link  
  visibility: ['public', 'private']
}  

# 15) Generar los modelos con: 
# rails g model user first_name:string last_name:string role:string status:string email:string auth_token:string
# rails g model post status:string core:string title:string content:string link:string user:references

# 16) Crear archivo post_spec.rb en spec
require 'rails_helper'  
RSpec.describe Post, type: :model do  
  describe "validations" do  
    it "should validate presence of required fields" do  
      should validate_presence_of(:title)  
      should validate_presence_of(:content)  
      should validate_presence_of(:link)  
      should validate_presence_of(:status)  
      should validate_presence_of(:core)  
      should validate_presence_of(:user_id)
      should validate_presence_of(:visibility)  
    end  
  end  
end  
# 17) Crear archivo user_spec.rb en spec
require 'rails_helper'  
RSpec.describe User, type: :model do  
  describe "validations" do  
    it "should validate presence of required fields" do  
      should validate_presence_of(:first_name)  
      should validate_presence_of(:last_name)  
      should validate_presence_of(:status)  
      should validate_presence_of(:role)  
      should validate_presence_of(:email)  
      should validate_presence_of(:auth_token)  
    end  
    it "should validate relations" do  
      should have_many(:posts)  
    end  
  end  
end  

# 18) Hacer pasar los tests modificando los modelos user y post
class User < ApplicationRecord  
  has_many :posts  
  validates :first_name, presence: true  
  validates :last_name, presence: true  
  validates :role, presence: true  
  validates :status, presence: true  
  validates :email, presence: true  
  validates :auth_token, presence: true  
end  

class Post < ApplicationRecord  
  belongs_to :user  
  validates :content, presence: true  
  validates :title, presence: true  
  validates :link, presence: true  
  validates :status, presence: true  
  validates :core, presence: true  
  validates :user_id, presence: true  
  validates :visibility, presence: true  
end  

# 19) Crear modelos de factory bot para post y user
# rails g factory_bot:model user first_name:string last_name:string role:string status:string email:string auth_token:string
# rails g factory_bot:model post title:string content:string link:string status:string type:string visibility:string user:references

# 20) Crear test de routing de posts (posts_spec.rb) en spec/requests
require "rails_helper"  
RSpec.describe "posts endpoint", type: :request do  
  describe "tasks" do
    describe "GET /tasks" do
      it "should return OK" do
        get '/tasks'
        payload = JSON.parse(response.body)
        expect(payload).to be_empty
        expect(response).to have_http_status(200)
      end
      describe "with data in the database" do
        let!(:posts) { create_list(:post, 10, {status: "published", core: "task"}) } 
        it "should return all the published tasks" do
          get '/tasks'
          payload = JSON.parse(response.body)
          expect(payload.size).to eq(posts.size)
          expect(payload.select{ |task| task["core"] == "task"}.size == posts.size).to be true
          expect(response).to have_http_status(200)
        end
      end
    end
    describe "GET /tasks/{id}" do
      let!(:post) { create(:post) }
      it "should return a specific post" do
        get "/tasks/#{post.id}"
        payload = JSON.parse(response.body)
        expect(payload).not_to be_empty
        expect(payload["id"]).to eq(post.id)
      end
    end
  end  
end  

# 21) Modificar los factory-bot en test/factories
# users.rb
FactoryBot.define do  
  factory :user do  
    first_name { Faker::Name.first_name }  
    last_name { Faker::Name.last_name }  
    role { "user" }  
    status { "active" }  
    email { Faker::Internet.email }  
    auth_token { "xxxxx" }  
  end  
end  
# posts.rb
FactoryBot.define do  
  factory :post do  
    title { Faker::Lorem.sentence }  
    content { Faker::Lorem.paragraph }  
    link { Faker::Internet.url }  
    status {   
      r = rand(0..2)  
      if r == 0  
        "pending"  
      elsif r == 1  
        "published"  
      elsif r == 2  
        "deleted"  
      end  
     }  
    visibility {  
      r = rand(0..1)  
      if r == 0  
        "public"  
      elsif r == 1  
        "private"  
      end 
     }  
     core {  
      r = rand(0..3)  
      if r == 0  
        "note"  
      elsif r == 1  
        "task"  
      elsif r == 2  
        "link"  
      elsif r == 3  
        "article"  
      end  
     }  
    user  
  end  
end  

# 22) Crear un controlador llamado posts_controller.rb en la carpeta controllers
class PostsController < ApplicationController 
  "#" GET /tasks
  def published_tasks
    @posts = Post.where(status: "published")
    render json: @posts, status: :ok
  end
  "#" GET /tasks/{id}
  def task
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end
end

# 23) Agregar rutas en config/routes.rb
Rails.application.routes.draw do  
  get '/health', to: 'health#health'  
  get '/tasks', to: 'posts#published_tasks'  
  get '/tasks/:id', to: 'posts#task'  
end  

# 24) Crear tests para la creacion de posts en spec/requests/posts_spec.rb
require "rails_helper"  
require "byebug"  
RSpec.describe "posts endpoint", type: :request do  
  describe "tasks" do  
    describe "GET /tasks" do  
      it "should return OK" do  
        get '/tasks'  
        payload = JSON.parse(response.body)  
        expect(payload).to be_empty  
        expect(response).to have_http_status(200)  
      end  
      describe "with data in the database" do  
        let!(:posts) { create_list(:post, 10, {status: "published", core: "task"}) }  
        it "should return all the published tasks" do  
          get '/tasks'  
          payload = JSON.parse(response.body)  
          expect(payload.size).to eq(posts.size)  
          expect(payload.select{ |task| task["core"] == "task"}.size == posts.size).to be true  
          expect(response).to have_http_status(200)  
        end  
      end  
    end  
    describe "GET /tasks/{id}" do  
      let!(:post) { create(:post) }  
      it "should return a specific post" do  
        get "/tasks/#{post.id}"  
        payload = JSON.parse(response.body)  
        expect(payload).not_to be_empty  
        expect(payload["id"]).to eq(post.id)  
      end  
    end  
    describe "POST /posts" do  
      let!(:user) { create(:user) }  
      it "should create a post" do  
        req_payload = {  
          post: {  
            title: "title",  
            content: "content",  
            link: "link.com/asd",  
            status: "pending",  
            core: "task",  
            visibility: "private",  
            user_id: user.id  
          }  
        }  
        post "/posts", params: req_payload  
        payload = JSON.parse(response.body)  
        expect(payload).not_to be_empty  
        expect(payload["id"]).not_to be_nil   
        expect(response).to have_http_status(:created)  
      end  
      it "should return error message when invalid post" do  
        req_payload = {  
          post: {  
            title: "title",  
            content: "content",  
            link: "link.com/asd",  
            status: "pendingadasd",  
            core: "taskasdad",
            visibility: "ddssdsds",    
            user_id: user.id  
          }  
        }  
        post "/posts", params: req_payload  
        payload = JSON.parse(response.body)  
        expect(payload).not_to be_empty  
        expect(payload["error"]).not_to be_empty  
        expect(response).to have_http_status(:unprocessable_entity)  
      end  
    end  
    describe "PUT /posts/{id}" do  
      let!(:item) { create(:post) }  
      it "should update a post" do  
        req_payload = {  
          post: {  
            title: "title 2",  
            content: "content 2",  
            link: "link.com/asd2",  
            status: "published",  
            core: "link",  
            visibility: "public"  
          }  
        }  
        put "/posts/#{item.id}", params: req_payload  
        payload = JSON.parse(response.body)  
        expect(payload).not_to be_empty  
        expect(payload["id"]).to eq(item.id)  
        expect(response).to have_http_status(:ok)  
      end  
      it "should return error message on invalid post" do  
        req_payload = {  
          post: {  
            title: "title",  
            content: "content",  
            link: "link.com/asd",  
            status: "pendingadasd",  
            core: "taskasdad",  
            visibility: "sddfee"  
          }  
        }  
        put "/posts/#{item.id}", params: req_payload  
        payload = JSON.parse(response.body)  
        expect(payload).not_to be_empty  
        expect(payload["error"]).not_to be_empty  
        expect(response).to have_http_status(:unprocessable_entity)  
      end  
    end  
  end  
end  
# 25) Agregar los métodos al controlador de posts en controllers/posts_controller.rb
  "#" POST /posts  
  def create  
    @post = Post.create!(create_params)  
    render json: @post, status: :created  
  end  
  "#" PUT /posts/{id}  
  def update  
    @post = Post.find(params[:id])  
    @post.update!(update_params)  
    render json: @post, status: :ok  
  end  
  private  
  def create_params  
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility, :user_id)  
  end  
  def update_params  
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)  
  end  
# 26) Agregar las rutas en config/routes.rb
get '/public/tasks', to: 'posts#published_public_tasks'  
post '/posts', to: 'posts#create'
put '/posts/:id', to: 'posts#update'
# 27) Manejar excepciones en controllers/posts_controller.rb
class PostsController < ApplicationController    
  rescue_from Exception do |e|  
    render json: { error: e.message }, status: :internal_server_error  
  end  
  rescue_from ActiveRecord::RecordInvalid do |e|  
    render json: { error: "Los parámetros ingresados no son válidos" }, status: :unprocessable_entity  
  end  
  "#" GET /tasks  
  def published_tasks  
    @posts = Post.where(status: "published")  
    render json: @posts, status: :ok  
  end  
  "#" GET /tasks/{id}  
  def task  
    @post = Post.find(params[:id])  
    render json: @post, status: :ok  
  end  
  "#" POST /posts  
  def create  
    if create_params["visibility"] == "public" || create_params["visibility"] == "private" && create_params["status"] == "pending" || create_params["status"] == "published" && create_params["core"] == "link" || create_params["core"] == "note" || create_params["core"] == "task" || create_params["core"] == "article"  
      @post = Post.create!(create_params)    
      render json: @post, status: :created  
    else  
      raise ActiveRecord::RecordInvalid  
    end  
  end  
  "#" PUT /posts/{id}  
  def update  
    @post = Post.find(params[:id])  
    if update_params["visibility"] == "public" || update_params["visibility"] == "private" && update_params["status"] == "pending" || update_params["status"] == "published" && update_params["core"] == "link" || update_params["core"] == "note" || update_params["core"] == "task" || update_params["core"] == "article"  
      @post.update!(update_params)  
      render json: @post, status: :ok  
    else  
      raise ActiveRecord::RecordInvalid  
    end  
  end  
  private  
  def create_params  
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility, :user_id)  
  end  
  def update_params  
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)  
  end  
end  
# 28) Agregar esta gema en Gemfile y correr el comando bundle install
gem 'active_model_serializers', '~> 0.10.8'  
# 29) Generar un serializer con rails g serializer post
class PostSerializer < ActiveModel::Serializer  
  attributes :id, :title, :content, :link, :core, :status, :author, :visibility  
  def author  
    user = self.object.user  
    {  
      name: user["name"],  
      email: user["email"],  
      id: user["id"]  
    }  
  end  
end  
# 30) Añadir tests en spec/requests/posts_spec.rb
describe "GET /tasks/{id}" do  
      let!(:post) { create(:post) }  
      it "should return a specific post" do  
        get "/tasks/#{post.id}"  
        payload = JSON.parse(response.body)  
        expect(payload).not_to be_empty  
        expect(payload["id"]).to eq(post.id)  
        expect(payload["title"]).to eq(post.title)  
        expect(payload["content"]).to eq(post.content)  
        expect(payload["link"]).to eq(post.link)  
        expect(payload["core"]).to eq(post.core)  
        expect(payload["visibility"]).to eq(post.visibility)  
        expect(payload["status"]).to eq(post.status)  
        expect(payload["author"]["name"]).to eq(post.user["name"])  
        expect(payload["author"]["email"]).to eq(post.user["email"])  
        expect(payload["author"]["id"]).to eq(post.user["id"])  
        expect(response).to have_http_status(200)  
      end  
    end  
  
# 31) Crear otro factory_bot para posts publicados en test/factories/posts.rb
factory :published_post, class: "Post" do  
    title { Faker::Lorem.sentence }  
    content { Faker::Lorem.paragraph }  
    link { Faker::Internet.url }  
    status { "published" }  
    core {  
      r = rand(0..3)  
      if r == 0  
        "note"  
      elsif r == 1  
        "task"  
      elsif r == 2  
        "link"  
      elsif r == 3  
        "article"  
      end  
     }  
    visibility {  
      r = rand(0..1)  
      if r == 0  
        "public"  
      elsif r == 1  
        "private"  
      end  
    }  
    user  
  end  
# 32) Crear prueba para filtrado de posts en spec/requests/posts_spec.rb
describe "GET /tasks" do  
      it "should return OK" do  
        get '/tasks'  
        payload = JSON.parse(response.body)  
        expect(payload).to be_empty  
        expect(response).to have_http_status(200)  
      end  
      describe "with data in the database" do  
        let!(:posts) { create_list(:post, 10, {status: "published", core: "task"}) }   
        it "should return all the published tasks" do  
          get '/tasks'  
          payload = JSON.parse(response.body)  
          expect(payload.size).to eq(posts.size)  
          expect(payload.select{ |task| task["core"] == "task"}.size == posts.size).to be true  
          expect(response).to have_http_status(200)  
        end  
      end  
      describe "Search" do  
        let!(:hola_mundo) { create(:published_post, title: "Hola mundo") }  
        let!(:hola_rails) { create(:published_post, title: "Hola rails") }  
        let!(:curso_rails) { create(:published_post, title: "Curso rails") }  
        it "should filter posts by title" do  
          get '/tasks?search=Hola'  
          payload = JSON.parse(response.body)  
          expect(payload).not_to be_empty  
          expect(payload.map { |post| post["id"] }.sort).to eq([hola_mundo.id, hola_rails.id].sort)  
          expect(payload.size).to eq(2)  
        end  
      end  
    end  
# 33) Modificar método de controlador en controllers/posts_controller.rb
"#" GET /tasks
  def published_tasks
    @posts = Post.where(status: "published")  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end  
"#" GET /public/tasks  
  def published_public_tasks  
    @posts = Post.where(status: "published", visibility: "public")  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end  
# 34) Crear archivo posts_search_service.rb en services
class PostsSearchService < ApplicationController  
  def self.search(curr_posts, query)  
    curr_posts.where("title LIKE '%#{query}%'")  
  end  
end  
# 35) Solucionar problema N+1 Query Problem en controllers/posts_controller.rb
 "#" GET /tasks  
  def published_public_tasks  
    @posts = Post.where(status: "published", visibility: "public").includes(:user)  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end  
# 36) Crear private_posts_spec.rb en spec/requests
require 'rails_helper'  
RSpec.describe "Tasks with authentication", type: :request do  
  let!(:user) { create(:user) }  
  let!(:other_user) { create(:user) }  
  let!(:user_post) { create(:post, user_id: user.id) }  
  let!(:other_user_post_public) { create(:post, user_id: other_user.id, visibility: "public") }  
  let!(:other_user_post_private) { create(:post, user_id: other_user.id, visibility: "private") }  
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, visibility: "public", status: "pending") }  
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}"}}  
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}"}}  
  describe "GET /tasks/{id}" do  
    context "with valid auth" do  
      context "when requesting other's author task" do  
        describe "when task is public" do  
            before { get "/tasks/#{other_user_post_public.id}", headers: auth_headers }   
          context "payload" do  
            subject { JSON.parse(response.body) }  
            it { is_expected.to include(:id) }  
          end  
          context "response" do  
            subject { response }  
            it { is_expected.to have_http_status(:ok) }  
          end  
        end  
        describe "when post is draft" do  
          before { get "/tasks/#{other_user_post_draft.id}", headers: auth_headers }   
          context "payload" do  
            subject { JSON.parse(response.body) }  
            it { is_expected.to include(:error) }  
          end  
          context "response" do  
            subject { response }  
            it { is_expected.to have_http_status(:not_found) }  
          end  
        end  
        describe "when post is private" do  
          before { get "/tasks/#{other_user_post_private.id}", headers: auth_headers }   
          context "payload" do  
            subject { JSON.parse(response.body) }  
            it { is_expected.to include(:error) }  
          end  
          context "response" do  
            subject { response }  
            it { is_expected.to have_http_status(:not_found) }  
          end  
        end  
      end  
      context "when requesting user's post" do  
      end  
    end  
  end  
  describe "POST /posts/{id}" do  
  end  
  describe "PUT /posts/{id}" do  
  end  
end  
# Autenticación con Tokens

# 37) Modificar el modelo de usuario en models/user.rb
class User < ApplicationRecord  
  has_many :posts  
  validates :first_name, presence: true  
  validates :last_name, presence: true  
  validates :role, presence: true  
  validates :status, presence: true  
  validates :email, presence: true  
  validates :auth_token, presence: true  
  after_initialize :generate_auth_token  
  def generate_auth_token  
    unless auth_token.present?  
      self.auth_token = TokenGenerationService.generate  
    end  
  end  
end  
# 38) Crear el servicio TokenGeneration en services/token_generation_service
class TokenGenerationService  
  def self.generate  
    SecureRandom.hex  
  end  
end  
# 39) Eliminar el auth_token del factory_bot de users en test/factories/users.rb ya que se hará automáticamente por el servicio.
# 40) Cambiar la lógica de auth en controllers/posts_controller.rb
class PostsController < ApplicationController  
  before_action :authenticate_user!, only: [:update, :create]  
  ...  
  ...  
  ...  
  ...  
  private  
  def create_params  
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility, :user_id)  
  end  
  def update_params  
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)  
  end  
  def authenticate_user!  
    token_regex = /Bearer (\w+)/  
    headers = request.headers  
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)  
      token = headers['Authorization'].match(token_regex)[1]  
      if(Current.user = User.find_by_auth_token(token))  
        return  
      end  
    end  
    render json: {error: "Unauthorized"}, status: :unauthorized  
  end  
end  
# 41) Implementar clase current en models/current.rb para que la sesión persista
class Current < ActiveSupport::CurrentAttributes  
  attribute :user  
end  
# 42) Modificar el metodo create_params en controllers/posts_controller.rb, para que ya no permitamos cambiar el user id
# ANTES
def create_params
  params.require(:post).permit(:title, :content, :link, :status, :core, :visibility, :user_id)
end
# DESPUES
def create_params
  params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)
end
# 43) Cambiar los métodos create y update para solo permitir cambiar o crear un post propio
  # POST /posts  
  def create  
    if create_params["visibility"] == "public" || create_params["visibility"] == "private" && create_params["status"] == "pending" || create_params["status"] == "published" && create_params["core"] == "link" || create_params["core"] == "note" || create_params["core"] == "task" || create_params["core"] == "article"  
      @post = Current.user.posts.create!(create_params)  
      render json: @post, status: :created  
    else  
      raise ActiveRecord::RecordInvalid  
    end  
  end  
  # PUT /posts/{id}  
  def update  
    @post = Current.user.posts.find(params[:id])  
    if update_params["visibility"] == "public" || update_params["visibility"] == "private" && update_params["status"] == "pending" || update_params["status"] == "published" && update_params["core"] == "link" || update_params["core"] == "note" || update_params["core"] == "task" || update_params["core"] == "article"  
      @post.update!(update_params)  
      render json: @post, status: :ok  
    else  
      raise ActiveRecord::RecordInvalid  
    end  
  end  

# 44) En el mismo archivo controlador, gestionar las peticiones GET para limitar las posibilidades y cumplir con los tests
  "#" GET /tasks  
  def published_tasks  
    @posts = Post.where(status: "published", user_id: Current.user.id)  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end  
  "#" GET /public/tasks  
  def published_public_tasks  
    @posts = Post.where(status: "published", visibility: "public").includes(:user)    
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end  
  "#" GET /tasks/{id}  
  def task  
    @post = Post.find(params[:id])  
    if(@post.user_id == Current.user && Current.user.id || @post.visibility == "public")  
      if(@post.user_id != Current.user && @post.status == "pending")  
        render json: { error: "404 Not Found"}, status: :not_found  
      else  
        render json: @post, status: :ok  
      end  
    else  
      render json: { error: "404 Not Found"}, status: :not_found  
    end  
  end  



