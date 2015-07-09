class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.references :user, index: true, foreign_key: true
      t.date      :date,        index: true
      t.time      :start_time
      t.text      :series,      array: true
      t.integer   :min_in_bed
      t.integer   :min_awake
      t.integer   :min_asleep
      t.integer   :min_fall_asleep
      t.integer   :min_restless
      t.integer   :awakening_count
      t.json      :heart_rate_zones

      t.timestamps null: false
    end
  end
end
