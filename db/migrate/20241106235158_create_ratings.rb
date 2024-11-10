class CreateRatings < ActiveRecord::Migration[6.0]
  def change
    create_table :ratings, id: :uuid do |t|
      t.uuid :post_id, null: false, foreign_key: true
      t.uuid :user_id, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_foreign_key :ratings, :posts, column: :post_id
    add_foreign_key :ratings, :users, column: :user_id
    add_index :ratings, [:post_id, :user_id], unique: true
  end
end