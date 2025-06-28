class AddLocTypeToAisles < ActiveRecord::Migration[7.1]
  def change
    add_column :aisles, :loc_type, :integer
  end
end
