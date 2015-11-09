class CarriageTemplate < ActiveRecord::Base
  MIN_SECTION_SIZE = 1
  has_many :different_areas
  has_many :products
  belongs_to :user

  default_scope {order("updated_at desc")}

  accepts_nested_attributes_for :different_areas, allow_destroy: true

  before_destroy :confirm_products_is_nil
  amoeba do
    enable
    append name: "的副本"
    include_association :different_areas
  end

  validates :name, presence: true

  validate do
    if self.different_areas.size < MIN_SECTION_SIZE
      self.errors.add(:base, "至少添加 #{MIN_SECTION_SIZE} 个配送区域")
    end
  end

  def total_carriage(count, province)
    template = find_template_by_address(province)
    calculate_price(count, template)
  end

  private
  def calculate_price(count, template)
    if template.present?
      balance = count - template.first_item
      extend_count = balance > 0 ? balance : 0

      template.carriage + extend_count * template.extend_carriage
    else
      0
    end
  end

  #address is provinces name
  def find_template_by_address(address)
    area = different_areas.joins(:regions).where(regions: {name: address}).first
    area = different_areas.joins(:regions).where(regions: {name: '其他'}).first if area.blank?
    area
  end

  def confirm_products_is_nil
    errors[:base] << '模板已被引用不能删除' if products.present?
    errors.blank?
  end
end
