class CreatePostUser < ActiveRecord::Migration[6.0]
  def change
    create_table :post_users do |t|
      t.integer "post_id"
      t.integer "user_id"
      t.string "permission"
    end
  end
end
