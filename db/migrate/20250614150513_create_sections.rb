class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.string :sectionnum
      t.integer :sec_depth
      t.integer :sec_height
      t.references :aisle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
