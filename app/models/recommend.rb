class Recommend < ActiveRecord::Base
  belongs_to :user

  scope :products, -> {where(recommended_type: ['ServiceProduct', 'OrdinaryProduct'])}
  scope :stores, -> {where(recommended_type: ['ServiceStore', 'OrdinaryStore'])}

  validates :recommended_id, :recommended_type, :user_id, presence: true

  def recommended
    recommended_type.constantize.find(recommended_id)
  end

  def recommended= object
    self.recommended_id = object.id
    self.recommended_type = object.class
  end
end
