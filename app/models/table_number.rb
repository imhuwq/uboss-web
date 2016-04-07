class TableNumber < ActiveRecord::Base
  has_many   :calling_notifies, dependent: :destroy
  belongs_to :user

  enum status: { unuse: 0, used: 1 }

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
    if number && (table_number = find_by(user: seller, number: number))
      table_number.update(status: 0)
      table_number.calling_notifies.destroy_all
    end
  end
end
