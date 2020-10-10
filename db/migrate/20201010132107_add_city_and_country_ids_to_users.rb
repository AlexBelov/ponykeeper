class AddCityAndCountryIdsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :country_id, :integer
    add_column :users, :city_id, :integer
  end
end
