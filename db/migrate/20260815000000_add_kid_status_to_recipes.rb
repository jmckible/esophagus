class AddKidStatusToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :kid_status, :string
  end
end
