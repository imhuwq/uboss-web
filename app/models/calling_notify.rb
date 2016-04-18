class CallingNotify < ActiveRecord::Base
  belongs_to :user
  belongs_to :table_number
  belongs_to :calling_service

  enum status: { unservice: 0, serviced: 1 }

  before_create :init_called_at
  after_save    :trigger_realtime_message, if: -> { status_changed? && serviced?}

  validates :user, :table_number, :calling_service, :status, presence: true
  validates :table_number_id, uniqueness: { scope: [:user_id, :calling_service_id]}
  #validates :calling_service_id, uniqueness: { scope: [:user_id, :table_number_id]}

  def service_name
    @name || calling_service.try(:name)
  end

  def calling_number
    @number || table_number.try(:number)
  end

  private
  def init_called_at
    self.called_at = Time.now
  end

  def trigger_realtime_message
    if self.service_name == "结帐"
      TableNumber.clear_seller_table_number(self.user, self.calling_number)
      checkout = true
    end

    message = {
      type: 'change_status',
      calling_notify_id: self.id,
      calling_number: self.calling_number,
      checkout: checkout || false
    }

    $redis.publish 'realtime_msg', { msg: message, recipient_user_ids: [self.user_id] }.to_json
  end
end
