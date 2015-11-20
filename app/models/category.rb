class Category < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :products, -> { uniq }

  validates_presence_of :user_id, :name
  validates :name, uniqueness: { scope: :user_id, message: :exists }
end
