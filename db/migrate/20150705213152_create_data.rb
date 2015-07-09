class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.references :user, index: true, foreign_key: true
      t.date  :date,        index: true
      t.time  :start_time
      t.text  :series,      array: true
      t.time  :time_in_bed
      t.time  :time_awake
      t.time  :time_asleep

      t.timestamps null: false
    end
  end
end
