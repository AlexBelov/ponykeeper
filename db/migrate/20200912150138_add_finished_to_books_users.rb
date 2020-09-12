class AddFinishedToBooksUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :books_users, :finished, :boolean, default: false, null: false
  end
end
