class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :HFB
      t.string :PA
      t.string :SALESMETHOD
      t.integer :BASEONHAND
      t.string :ARTNO
      t.string :ARTNAME_UNICODE
      t.integer :CP_LENGTH
      t.integer :CP_WIDTH
      t.integer :CP_HEIGHT
      t.integer :WEIGHT_G
      t.string :SLID_H
      t.integer :MPQ
      t.integer :PALQ
      t.string :SSD
      t.string :EDS
      t.integer :UL_HEIGHT_GROSS
      t.integer :UL_LENGTH_GROSS
      t.integer :UL_WIDTH_GROSS
      t.string :new_slid
      t.integer :new_assq
      t.integer :DTFP
      t.integer :DTFP_PLUS
      t.integer :RSSQ
      t.boolean :planned
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
