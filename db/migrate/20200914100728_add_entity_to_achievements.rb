class AddEntityToAchievements < ActiveRecord::Migration[6.0]
  def change
    add_column :achievements, :entity, :integer, default: 0, after: :id
  end
end
