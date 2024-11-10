class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.uuid :user_id, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.string :ip, null: false

      t.timestamps
    end

    add_foreign_key :posts, :users, column: :user_id
    add_index :posts, :user_id
  end
end
