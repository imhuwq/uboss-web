class ProductPropertyValue < ActiveRecord::Base

  belongs_to :product_property
  belongs_to :product_class

  validates :value, presence: true, uniqueness: { scope: :product_property_id }
  validates_presence_of :product_property_id

  def to_json
    {
      id: id,
      value: value
    }
  end

end
