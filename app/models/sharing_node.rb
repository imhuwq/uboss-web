class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  validates :user_id, :product_id, :code, precense: true

end
