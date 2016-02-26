class Recommend < ActiveRecord::Base
  belongs_to :user
  belongs_to :recommended, :polymorphic => true

  scope :products, -> {where(recommended_type: ['ServiceProduct', 'OrdinaryProduct'])}
  scope :stores, -> {where(recommended_type: ['ServiceStore', 'OrdinaryStore'])}

  validates :recommended_id, :recommended_type, :user_id, presence: true
  validates :user_id, :uniqueness => {:scope => [:recommended_type, :recommended_id]}
end
