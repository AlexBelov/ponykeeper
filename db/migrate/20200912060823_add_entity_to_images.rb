class AddEntityToImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :entity, :integer, default: 0
  end
end
