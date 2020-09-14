class AddUserIdToAdmins < ActiveRecord::Migration[6.0]
  def change
    add_column :admins, :user_id, :integer
  end
end
