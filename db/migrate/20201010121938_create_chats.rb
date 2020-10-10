class CreateChats < ActiveRecord::Migration[6.0]
  def change
    create_table :chats do |t|
      t.string :telegram_id
      t.integer :role
      t.string :title
      t.string :group_type

      t.timestamps
    end
  end
end
