class CreateRanksUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :ranks_users do |t|
      t.integer :rank_id
      t.integer :user_id

      t.timestamps
    end
  end
end
