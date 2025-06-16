class Level < ApplicationRecord
  belongs_to :section

  has_and_belongs_to_many :articles

  def full_level_code
    # Extract aisle number from section.sectionnum ("64-1" -> "64")
    aisle_part = section.sectionnum.split("-").first

    # Extract suffix from section.sectionnum ("64-1" -> "01")
    section_part = section.sectionnum.split("-").last.to_i.to_s.rjust(2, "0")

    # Combine to form full code: 64 + 01 + 00 = "640100"
    "#{aisle_part}#{section_part}#{level_num}"
  end
end
