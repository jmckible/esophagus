class AddSectionToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :section_id, :integer
    add_index  :recipes, [:section_id, :name]
  end
end
