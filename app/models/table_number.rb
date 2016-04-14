class TableNumber < ActiveRecord::Base
  has_many   :calling_notifies, dependent: :destroy
  belongs_to :user

  enum status: { unuse: 0, used: 1 }

  before_save :set_expired_at
  after_save  :destroy_all_calling_notifies, if: -> { status_changed? && unuse? }

  validates :user, :number, :status, presence: true
  validates :number, uniqueness: { scope: :user_id }

  def self.reset_store_table_numbers(count, user_id)
    destroy_all(user_id: user_id)
    values = (1..count).inject([]){ |data, i| data << "(#{user_id}, #{i}, '#{DateTime.now}', '#{DateTime.now}')" }
    ActiveRecord::Base.connection.execute <<-SQL.squish!
      INSERT INTO table_numbers (user_id, number, created_at, updated_at) VALUES #{values.join(',')};
    SQL
  end

  def self.clear_seller_table_number(seller, number)
    if table_number = find_by(user: seller, number: number)
      table_number.update(status: 'unuse', expired_at: nil)
    end
  end

  private

  def set_expired_at
    if status == "used"
      self.expired_at = Time.now + user.service_store.table_expired_in.minutes
    end
  end

  def destroy_all_calling_notifies
    self.calling_notifies.destroy_all
  end
end
