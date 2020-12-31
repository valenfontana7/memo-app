require 'rails_helper'

RSpec.describe "Tasks with authentication", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:other_user_post) { create(:post, user_id: other_user.id) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}"}}
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}"}}

  describe "GET /tasks/{id}" do
    context "with valid auth" do
      context "when requesting other's author post" do
        
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