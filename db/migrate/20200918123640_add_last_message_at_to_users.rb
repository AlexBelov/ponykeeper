class AddLastMessageAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_message_at, :datetime
  end
end
