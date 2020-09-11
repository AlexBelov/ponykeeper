class AddAbvAndVolumeToDrinksUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :drinks_users, :abv, :decimal, precision: 10, scale: 2
    add_column :drinks_users, :volume, :decimal, precision: 10, scale: 2
  end
end
