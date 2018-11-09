class AddCounterCacheToRecipes < ActiveRecord::Migration[5.2]
  def up
    add_column :recipes, :last_cooked_on, :date
    add_column :recipes, :cooks_count, :integer, default: 0

    Recipe.reset_column_information
    Recipe.all.find_each do |r|
      Recipe.reset_counters r.id, :cooks
      last = r.cooks.reorder(date: :asc).last
      r.update_attribute :last_cooked_on, last.date if last
    end
  end

  def down
    remove_column :recipes, :last_cooked_on
    remove_column :recipes, :cooks_count
  end
end
