class AddScoresToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :drink_score, :decimal, precision: 10, scale: 2
    add_column :users, :book_score, :decimal, precision: 10, scale: 2
  end
end
