class SupplierProductInfo < ActiveRecord::Base

  include Descriptiontable

  before_save :set_default_suggest_price_lower, if: Proc.new { |spi| spi.suggest_price_lower.nil? }

  enum supply_status: [:stored, :supplied, :deleted]

  validates :cost_price, presence: true
  validates :cost_price, numericality: { greater_than: 0 }, if: -> { cost_price.present? }
  validates :suggest_price_lower, :suggest_price_upper, numericality: { greater_than: 0, allow_nil: true }
  validates_numericality_of :suggest_price_upper, greater_than: ->(spi){ spi.suggest_price_lower },  if: -> { suggest_price_lower.present? and suggest_price_upper.present? }
  validates_numericality_of :suggest_price_lower, greater_than_or_equal_to: ->(spi){ spi.cost_price }, if: -> { cost_price.present? and suggest_price_lower.present? }

  belongs_to :supplier_product
  belongs_to :supplier, class_name: 'User'

  private

  def set_default_suggest_price_lower
    self.suggest_price_lower = self.cost_price
  end

end
