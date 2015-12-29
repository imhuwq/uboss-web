class ServiceStore < UserInfo
  MIN_SECTION_SIZE = 1
  has_many :store_phones, autosave: true
  has_many :service_products

  validates_uniqueness_of :user_id, message: :only_ordinary_store
  validates :begin_hour, :begin_minute, :end_hour, :end_minute, :province, :city, :area, :store_name, presence: true
  validates :begin_hour, :end_hour, inclusion: { in: '1'..'24', message: "必须在1-24小时之间" }
  validates :begin_minute, :end_minute, inclusion: { in: '00'..'60', message: "必须在00-60分钟之间" }

  accepts_nested_attributes_for :store_phones, allow_destroy: true

  validate do
    if self.store_phones.size < MIN_SECTION_SIZE
      self.errors.add(:store_phones, "至少包含一条信息")
    end

    if (begin_hour.to_i > end_hour.to_i) || (begin_hour.to_i == end_hour.to_i && begin_minute.to_i >= end_minute.to_i)
      self.errors.add(:begin_time, '不能大于或等于结束时间')
    end
  end

  def total_evaluat_people
    service_products.map do |product|
      product.worst_evaluation.to_i + product.good_evaluation.to_i +
        product.bad_evaluation.to_i + product.better_evaluation.to_i +
        product.best_evaluation.to_i
    end.sum
  end

  def total_good_reputation
    total_evalution = 0.0
    good_reputation = 0
    service_products.each do |product|
      total_evalution += product.good_evaluation.to_f + product.bad_evaluation.to_f + product.worst_evaluation.to_f + product.best_evaluation.to_f + product.better_evaluation.to_f
      good_reputation += product.good_evaluation.to_i + product.best_evaluation.to_i + product.better_evaluation.to_i
    end
    rate = total_evalution > 0 ? good_reputation/total_evalution.to_f : 1
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
