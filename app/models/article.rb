class Article < ApplicationRecord
  belongs_to :store

  has_and_belongs_to_many :levels
  has_many :sections, through: :levels

  before_validation :set_default_planned, on: :create

  private

  def set_default_planned
    self.planned = false if planned.nil?
  end
end
