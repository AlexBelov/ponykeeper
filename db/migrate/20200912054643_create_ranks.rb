class CreateRanks < ActiveRecord::Migration[6.0]
  def change
    create_table :ranks do |t|
      t.integer :entity, default: 0
      t.integer :threshold
      t.string :name

      t.timestamps
    end
  end
end
