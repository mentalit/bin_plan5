class Store < ApplicationRecord
	has_many :articles
	has_many :aisles
end
