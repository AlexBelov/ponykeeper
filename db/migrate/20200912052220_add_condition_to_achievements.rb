class AddConditionToAchievements < ActiveRecord::Migration[6.0]
  def change
    add_column :achievements, :condition, :text
    remove_column :achievements, :slug, :string
  end
end
