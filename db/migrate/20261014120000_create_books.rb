class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :cookbook, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :books, %i[cookbook_id name], unique: true

    add_reference :recipes, :book
    add_column :recipes, :book_page, :integer
  end
end
