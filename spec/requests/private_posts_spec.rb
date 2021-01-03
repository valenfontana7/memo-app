require 'rails_helper'

RSpec.describe "Tasks with authentication", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:user_post_draft) { create(:post, user_id: user.id, status: "pending") }
  let!(:user_post_deleted) { create(:post, user_id: user.id, status: "deleted") }
  let!(:other_user_post_public_published) { create(:post, user_id: other_user.id, visibility: "public", status: "published") }
  let!(:other_user_post_private_published) { create(:post, user_id: other_user.id, visibility: "private", status: "published") }
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, visibility: "public", status: "pending") }
  let!(:other_user_post_deleted) { create(:post, user_id: other_user.id, status: "deleted") }
  let!(:other_user_post) { create(:post, user_id: other_user.id) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}"}}
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}"}}
  let!(:create_params_task) { { "post" => { 'title' => "title", "content" => "content", "link" => "link", "status" => "published", "core" => "task", "visibility" => "public"} } }
  let!(:update_params_task) { { "post" => { 'title' => "title", "content" => "content", "link" => "link", "status" => "published", "core" => "task", "visibility" => "public"} } }

  describe "GET /tasks/{id}" do
    context "with valid auth" do
      context "when requesting other's author task" do
        context "when task is public" do
          context "when task is published" do
            before { get "/public/tasks/#{other_user_post_public_published.id}", headers: auth_headers } 
            context "payload" do
              subject { payload }
              it { is_expected.to include(:id) }
            end  
            context "response" do
              subject { response }
              it { is_expected.to have_http_status(:ok) }
            end 
          end  
          context "when task is draft" do
            before { get "/public/tasks/#{other_user_post_draft.id}", headers: auth_headers } 
            context "payload" do
              subject { payload }
              it { is_expected.to include(:error) }
            end  
            context "response" do
              subject { response }
              it { is_expected.to have_http_status(:not_found) }
            end   
          end
          context "when task is deleted" do
            before { get "/public/tasks/#{other_user_post_deleted.id}", headers: auth_headers } 
            context "payload" do
              subject { payload }
              it { is_expected.to include(:error) }
            end  
            context "response" do
              subject { response }
              it { is_expected.to have_http_status(:not_found) }
            end   
          end
        end
        context "when task is private" do
          before { get "/tasks/#{other_user_post_private_published.id}", headers: auth_headers } 
          context "payload" do
            subject { payload }
            it { is_expected.to include(:error) }
          end  
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end  
        end
      end
      context "when requesting user's post" do
        context "when task is published" do
          before { get "/tasks/#{user_post.id}", headers: auth_headers } 
          context "payload" do
            subject { payload }
            it { is_expected.to include(:id) }
          end  
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end 
        end  
        context "when task is draft" do
          before { get "/tasks/drafts/#{user_post_draft.id}", headers: auth_headers } 
          context "payload" do
            subject { payload }
            it { is_expected.to include(:id) }
          end  
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end 
        end
        context "when task is deleted" do
          before { get "/tasks/#{user_post_deleted.id}", headers: auth_headers } 
          context "payload" do
            subject { payload }
            it { is_expected.to include(:id) }
          end  
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end   
        end
      end
      context "when creating and updating posts" do
        describe "POST /posts/{id}" do
          before { post "/posts", params: create_params_task, headers: auth_headers } 
          context "payload" do
            subject { payload }
            it { is_expected.to include(:id, :title, :content, :status, :author, :link, :core, :visibility) }
          end  
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:created) }
          end   
        end
        describe "PUT /posts/{id}" do
          context "when updating user's post" do
            before { put "/posts/#{user_post.id}", params: update_params_task, headers: auth_headers } 
            context "payload" do
              subject { payload }
              it { is_expected.to include(:id, :title, :content, :status, :author, :link, :core, :visibility) }
              it { expect(payload[:id]).to eq(user_post.id) }
            end  
            context "response" do
              subject { response }
              it { is_expected.to have_http_status(:ok) }
            end 
          end
          context "when trying to update other's user post" do
            before { put "/posts/#{other_user_post.id}", params: update_params_task, headers: auth_headers } 
            context "payload" do
              subject { payload }
              it { is_expected.to include(:error) }
            end  
            context "response" do
              subject { response }
              it { is_expected.to have_http_status(:not_found) }
            end 
          end
        end
      end
    end
    context "with invalid auth" do
      context "when creating and updating posts" do
        describe "POST /posts/{id}" do
          before { post "/posts", params: create_params_task } 
          context "payload" do
            subject { payload }
            it { is_expected.to include(:error) }
          end  
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:unauthorized) }
          end   
        end
        describe "PUT /posts/{id}" do
          before { put "/posts/#{other_user_post.id}", params: update_params_task } 
            context "payload" do
              subject { payload }
              it { is_expected.to include(:error) }
            end  
            context "response" do
              subject { response }
              it { is_expected.to have_http_status(:unauthorized) }
            end 
        end
      end
    end
  end
  private
  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end