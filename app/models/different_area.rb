class DifferentArea < ActiveRecord::Base
  MIN_SECTION_SIZE = 1

  belongs_to :carriage_template
  has_and_belongs_to_many :regions

  amoeba do
    enable
    include_association :regions
  end

  validates :first_item, :carriage, :extend_item, :extend_carriage, presence: true

  validate do
    if self.regions.size < MIN_SECTION_SIZE
      self.errors.add(:base, "至少选择 #{MIN_SECTION_SIZE} 个省份")
    end
  end
end
