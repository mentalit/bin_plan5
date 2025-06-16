class CreateArticlesLevelsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :articles_levels do |t|
      t.references :article, null: false, foreign_key: true
      t.references :level, null: false, foreign_key: true

      t.timestamps
    end
  end
end
