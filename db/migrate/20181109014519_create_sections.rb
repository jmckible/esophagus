class CreateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.string :name
      t.references :cookbook, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :sections, [:cookbook_id, :position]
  end
end
