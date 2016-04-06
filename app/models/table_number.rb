class TableNumber < ActiveRecord::Base
  has_many   :calling_notifies, dependent: :destroy
  belongs_to :user

  enum status: { unuse: 0, used: 1 }

  validates :user, :number, :status, presence: true
  validates :number, uniqueness: { scope: :user_id }
end
