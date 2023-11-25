class CreateDays < ActiveRecord::Migration[7.1]
  def change
    create_table :days do |t|
      t.string :in_time
      t.string :out_time
      t.boolean :is_rest
      t.string :day_type
      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
