class CreateOrderedItems < ActiveRecord::Migration[6.0]
  def change
    create_table :ordered_items do |t|
      t.string :item_name, null: false
      t.string :name_key, null: false
      t.float :item_price
      t.float :packaging
      t.integer :no_of_items
      t.float :total_quantity
      t.float :price_per_kg
      t.string :item_hsn
      t.float :item_amount
      t.string :financial_year
      t.datetime :order_date

      t.references :user, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.references :invoice, index: true, foreign_key: true

      t.timestamps
    end
  end
end
