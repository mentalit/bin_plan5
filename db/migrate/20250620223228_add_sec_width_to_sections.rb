class AddSecWidthToSections < ActiveRecord::Migration[7.1]
  def change
    add_column :sections, :sec_width, :integer
  end
end
