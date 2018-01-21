class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name
      t.float :quarter_price
      t.float :one_tenth_price
      t.float :half_price
      t.float :bulk_price
      t.string :series

      t.timestamps
    end
  end
end
