class ProductPropertyValue < ActiveRecord::Base

  belongs_to :product_property
  belongs_to :product_class

  validates_uniqueness_of :value

  def to_json
    {
      id: id,
      value: value
    }
  end

end
