class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :venue
      t.datetime :start_date
      t.datetime :end_date
      t.integer :capacity
      t.references :event_organizer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
