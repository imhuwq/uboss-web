class ServiceStore < UserInfo
  MIN_SECTION_SIZE = 1
  has_many :store_phones, autosave: true
  has_many :service_products

  validates_uniqueness_of :user_id, message: :only_service_store
  validates :begin_hour, :begin_minute, :end_hour, :end_minute, :province, :city, :area, :store_name, :street, presence: true
  validates :begin_hour, :end_hour, inclusion: { in: '1'..'24', message: "必须在1-24小时之间" }
  validates :begin_minute, :end_minute, inclusion: { in: '00'..'60', message: "必须在00-60分钟之间" }
  validates :table_count,      numericality: { greater_than: 0 }, if: -> { self.table_expired_in > 0}
  validates :table_expired_in, numericality: { greater_than: 0 }, if: -> { self.table_count > 0}

  accepts_nested_attributes_for :store_phones, allow_destroy: true

  validate do
    if self.store_phones.size < MIN_SECTION_SIZE
      self.errors.add(:store_phones, "至少包含一条信息")
    end
  end

  def total_good_reputation_number
    @total_good_reputation_number ||= service_products.sum('COALESCE(good_evaluation,0) + COALESCE(better_evaluation,0) + COALESCE(best_evaluation,0)')
  end

  def total_bad_reputation_number
    @total_bad_reputation ||= service_products.sum('COALESCE(bad_evaluation,0) + COALESCE(worst_evaluation,0)')
  end

  def total_reputation_number
    total_good_reputation_number + total_bad_reputation_number
  end
  alias_method :total_evaluat_people, :total_reputation_number

  def total_good_reputation
    rate = total_reputation_number > 0 ? total_good_reputation_number/total_reputation_number.to_f : 1
    "#{'%.2f' % (rate*100)}%"
  end

  def mobile_phone
    phones = []
    store_phones.each do |phone|
      phones << phone.phone_number if phone.phone_number.present?
      phones << phone.fixed_phone  if phone.fixed_line.present?
    end
    phones
  end

  def store_cover_name
    store_cover.try(:file).try(:filename)
  end

  def address
    "#{ChinaCity.get(province)}#{ChinaCity.get(city)}#{ChinaCity.get(area)}#{street}"
  end

  def business_hours
    "#{begin_time}一#{end_time}"
  end

  def begin_time
    "#{begin_hour}:#{begin_minute}"
  end

  def end_time
    "#{end_hour}:#{end_minute}"
  end
end
