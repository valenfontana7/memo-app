require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "validations" do
    it "should validate presence of required fields" do
      should validate_presence_of(:title)
      should validate_presence_of(:content)
      should validate_presence_of(:link)
      should validate_presence_of(:status)
      should validate_presence_of(:core)  
      should validate_presence_of(:visibility)  
      should validate_presence_of(:user_id)
    end
  end
end