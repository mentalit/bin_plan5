class Section < ApplicationRecord
  belongs_to :aisle
  has_many :levels

   after_create :create_default_level

   after_create :create_default_level

  private

  def create_default_level
    levels.create!(
      level_num: "00",
      level_depth: sec_depth
    )
  end
end

