class AddCookbookToRecipe < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :cookbook_id, :integer
    add_index  :recipes, :cookbook_id
  end
end
