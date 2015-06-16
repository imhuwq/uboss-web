class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  validates :user_id, :product_id, :code, presence: true
  validates_uniqueness_of :code

  before_create :set_code

  private
  def set_code
    loop do
      self.code = SecureRandom.base64(16)
      break if !SharingNode.find_by(code: code)
    end
  end
end
