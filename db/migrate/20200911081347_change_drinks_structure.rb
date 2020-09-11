class ChangeDrinksStructure < ActiveRecord::Migration[6.0]
  def change
    remove_column :drinks, :url, :string
    add_column :drinks, :name, :string
  end
end
