class ProductPropertyValue < ActiveRecord::Base
  belongs_to :product_property
  belongs_to :product_class

  def to_json
    {
      id: id,
      value: value
    }
  end
end
