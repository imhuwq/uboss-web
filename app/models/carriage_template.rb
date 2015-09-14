class CarriageTemplate < ActiveRecord::Base
  MIN_SECTION_SIZE = 1
  has_many :different_areas
  accepts_nested_attributes_for :different_areas, :allow_destroy => true

  validates :name, presence: true

  validate do
    if self.different_areas.size < MIN_SECTION_SIZE
      self.errors.add(:base, "至少添加 #{MIN_SECTION_SIZE} 个配送区域")
    end
  end
end
