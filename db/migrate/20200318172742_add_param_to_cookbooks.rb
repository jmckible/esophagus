class AddParamToCookbooks < ActiveRecord::Migration[6.0]
  def change
    add_column :cookbooks, :param, :string
    add_index  :cookbooks, :param, unique: true
  end
end
