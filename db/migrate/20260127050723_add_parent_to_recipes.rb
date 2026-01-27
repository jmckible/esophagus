class AddParentToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :parent_id, :bigint
    add_index :recipes, :parent_id
    add_foreign_key :recipes, :recipes, column: :parent_id
  end
end
