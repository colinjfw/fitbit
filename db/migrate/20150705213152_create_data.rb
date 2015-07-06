class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.references :user, index: true, foreign_key: true
      t.date :day
      t.json :heart_series
      t.json :sleep_series

      t.timestamps null: false
    end
  end
end
