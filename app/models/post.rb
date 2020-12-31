class Post < ApplicationRecord
  belongs_to :user
  validates :content, presence: true
  validates :title, presence: true
  validates :link, presence: true
  validates :status, presence: true
  validates :core, presence: true
  validates :visibility, presence: true
  validates :user_id, presence: true
end
