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
        expect(payload["status"]).to eq(post.status)
        expect(payload["visibility"]).to eq(post.visibility)  
        expect(payload["author"]["name"]).to eq(post.user["name"])
        expect(payload["author"]["email"]).to eq(post.user["email"])
        expect(payload["author"]["id"]).to eq(post.user["id"])
        expect(response).to have_http_status(200)
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
            visibility: "prsdsadad",  
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
            visibility: "prisdsdade",  
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