class CreateAisles < ActiveRecord::Migration[7.1]
  def change
    create_table :aisles do |t|
      t.string :aislenum
      t.integer :aislestart
      t.integer :aisleend
      t.integer :aisledepth
      t.integer :aisleheight
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
