require "rails_helper"

RSpec.describe "posts endpoint", type: :request do
  let!(:user) { create(:user) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}"}}
  describe "tasks" do
    describe "GET /tasks" do
      it "should return OK" do
        get '/tasks', headers: auth_headers
        payload = JSON.parse(response.body)
        expect(payload).to be_empty
        expect(response).to have_http_status(200)
      end
      describe "with data in the database" do
        let!(:posts) { create_list(:post, 10, {status: "published", core: "task", user_id: user.id}) } 
        let!(:posts_2) { create_list(:post, 10, {status: "pending", core: "task", user_id: user.id}) } 
        it "should return all the published tasks" do
          get '/tasks', headers: auth_headers
          payload = JSON.parse(response.body)
          expect(payload.size).to eq(posts.size)
          expect(payload.select{ |task| task["core"] == "task"}.size == posts.size).to be true
          expect(response).to have_http_status(200)
        end
        it "should return all the pending tasks" do
          get '/tasks/drafts', headers: auth_headers
          payload = JSON.parse(response.body)
          expect(payload.size).to eq(posts_2.size)
          expect(payload.select{ |task| task["core"] == "task"}.size == posts_2.size).to be true
          expect(response).to have_http_status(200)
        end
      end
      describe "Search" do
        let!(:hola_mundo) { create(:post, core: "task", status: "published", title: "Hola mundo", user_id: user.id) }
        let!(:hola_rails) { create(:post, core: "task", status: "published", title: "Hola rails", user_id: user.id) }
        let!(:curso_rails) { create(:post, core: "task", status: "published", title: "Curso rails", user_id: user.id) }
        it "should filter posts by title" do
          get '/tasks?search=Hola', headers: auth_headers
          payload = JSON.parse(response.body)
          expect(payload).not_to be_empty
          expect(payload.map { |post| post["id"] }.sort).to eq([hola_mundo.id, hola_rails.id].sort)
          expect(payload.size).to eq(2)
        end
      end
    end
    describe "GET /tasks/{id}" do
      let!(:post) { create(:post, status: "published", user_id: user.id) }
      it "should return a specific post" do
        get "/tasks/#{post.id}", headers: auth_headers
        payload = JSON.parse(response.body)
        expect(payload).not_to be_empty
        expect(payload["id"]).to eq(post.id)
        expect(payload["title"]).to eq(post.title)
        expect(payload["content"]).to eq(post.content)
        expect(payload["link"]).to eq(post.link)
        expect(payload["core"]).to eq(post.core)
        expect(payload["status"]).to eq(post.status)
        expect(payload["visibility"]).to eq(post.visibility)  
        expect(payload["author"]["name"]).to eq(post.user["name"])
        expect(payload["author"]["email"]).to eq(post.user["email"])
        expect(payload["author"]["id"]).to eq(post.user["id"])
        expect(response).to have_http_status(200)
      end
    end
  end
  # describe "articles" do
  #   before { get '/articles' }

  #   it "should return OK" do
  #     payload = JSON.parse(response.body)
  #     expect(payload).not_to be_empty
  #     expect(payload['api']).to eq('OK')
  #   end

  #   it "should return status code 200" do
  #     expect(response).to have_http_status(200)
  #   end
  # end
end