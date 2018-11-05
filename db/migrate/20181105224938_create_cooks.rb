class CreateCooks < ActiveRecord::Migration[5.2]
  def change
    create_table :cooks do |t|
      t.references :recipe, foreign_key: true
      t.date :date

      t.timestamps
    end
  end
end
