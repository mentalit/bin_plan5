class Aisle < ApplicationRecord
  belongs_to :store
  has_many :sections
  
  after_create :generate_sections

  private

  def generate_sections
    range = (aislestart..aisleend).to_a

    range.each_slice(3).with_index(1) do |group, index|
      sections.create!(
        sectionnum: "#{aislenum}-#{index}",
        sec_depth: aisledepth,
        sec_height: aisleheight
      )
    end
  end
end


