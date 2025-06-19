class AddDtToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :DT, :string
  end
end
