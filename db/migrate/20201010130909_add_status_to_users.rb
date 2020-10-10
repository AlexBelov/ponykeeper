class AddStatusToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :integer, default: 0, null: false
  end
end
