class Aisle < ApplicationRecord
  belongs_to :store
  has_many :sections, dependent: :destroy

  enum loc_type: { shallow: 0, deep: 1 }
  
  after_create :generate_sections

  private

  def generate_sections(sec_width = 2921)
  range = (aislestart..aisleend).to_a

  range.each_slice(3).with_index(1) do |group, index|
    sections.create!(
      sectionnum: "#{aislenum}-#{index}",
      sec_depth: aisledepth,
      sec_height: aisleheight,
      sec_width: sec_width 
    )
 
    end
  end
end





