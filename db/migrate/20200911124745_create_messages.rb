class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :slug
      t.text :content

      t.timestamps
    end
  end
end
