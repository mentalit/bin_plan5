class CreateStores < ActiveRecord::Migration[7.1]
  def change
    create_table :stores do |t|
      t.string :storename
      t.string :storenum

      t.timestamps
    end
  end
end
