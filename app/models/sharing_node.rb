class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  belongs_to :user
  belongs_to :product

  validates :user_id, :product_id, presence: true
  validates_uniqueness_of :code

  before_create :set_code

  private
  def set_code
    loop do
      self.code = SecureRandom.hex(10)
      break if !SharingNode.find_by(code: code)
    end
  end
end
