class CreateTransports < ActiveRecord::Migration[6.0]
  def change
    create_table :transports do |t|
      t.string :name, :null => false
      t.string :location
      t.string :gst_no

      t.timestamps
    end

    add_index :transports, :gst_no,                unique: true
  end
end
