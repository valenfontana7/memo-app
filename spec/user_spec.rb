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