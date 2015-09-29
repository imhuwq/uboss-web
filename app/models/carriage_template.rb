class CarriageTemplate < ActiveRecord::Base
  MIN_SECTION_SIZE = 1
  has_many :different_areas
  has_many :products

  default_scope {order("updated_at desc")}

  accepts_nested_attributes_for :different_areas, allow_destroy: true

  before_destroy :confirm_products_is_nil
  amoeba do
    enable
    append name: "的副本"
    include_association :different_areas
  end

  validates :name, presence: true, uniqueness: true

  validate do
    if self.different_areas.size < MIN_SECTION_SIZE
      self.errors.add(:base, "至少添加 #{MIN_SECTION_SIZE} 个配送区域")
    end
  end

  private
  def confirm_products_is_nil
    errors[:base] << '模板已被引用不能删除' if products.present?
    errors.blank?
  end
end
