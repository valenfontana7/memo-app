class AddCoreColumn < ActiveRecord::Migration[6.0]
  def change
    drop_table :posts
    create_table :posts do |t|
      t.string :status
      t.string :core
      t.string :title
      t.string :content
      t.string :link
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
