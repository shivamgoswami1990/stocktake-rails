class AddDiscountToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :is_discount_enabled, :boolean, default: true
  end
end
