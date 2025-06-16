class Article < ApplicationRecord
  belongs_to :store

  has_and_belongs_to_many :levels
  has_many :sections, through: :levels
end
