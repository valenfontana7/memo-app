class Post < ApplicationRecord
  has_many :post_users
  has_many :users, :through => :post_users
  validates :content, presence: true
  validates :title, presence: true
  validates :link, presence: true
  validates :status, presence: true
  validates :core, presence: true
  validates :visibility, presence: true
end
