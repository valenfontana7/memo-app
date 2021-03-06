class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :status
      t.string :type
      t.string :title
      t.string :content
      t.string :link
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
