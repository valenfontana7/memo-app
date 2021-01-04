class User < ApplicationRecord
  has_secure_password
  before_save :set_defaults
  has_many :post_users
  has_many :posts, :through => :post_users
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :auth_token, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 105 }, uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL_REGEX }
  after_initialize :generate_auth_token


  def generate_auth_token
    unless auth_token.present?
      self.auth_token = TokenGenerationService.generate
    end
  end
  def set_defaults
    self.email = email.downcase
    self.role ||= "user"
    self.status ||= "active"
  end
end
