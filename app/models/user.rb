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
