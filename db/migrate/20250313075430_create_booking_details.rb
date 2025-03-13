class CreateBookingDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_details do |t|
      t.integer :quantity
      t.references :ticket, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true

      t.timestamps
    end
  end
end
