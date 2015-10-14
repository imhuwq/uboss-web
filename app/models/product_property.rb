class ProductProperty < ActiveRecord::Base

  belongs_to :product_class
  has_many :product_property_values, dependent: :destroy

  validates_uniqueness_of :name

  def to_json
    {
      id: id,
      name: name,
      property_values: product_property_values.map(&:to_json)
    }
  end

end
