class ServiceStore < UserInfo
  MIN_SECTION_SIZE = 1
  has_many :store_phones, autosave: true
  has_many :service_products

  validates_uniqueness_of :user_id, message: :only_ordinary_store
  validates :begin_hour, :begin_minute, :end_hour, :end_minute, :province, :city, :area, :store_name, presence: true

  accepts_nested_attributes_for :store_phones, allow_destroy: true

  validate do
    if self.store_phones.size < MIN_SECTION_SIZE
      self.errors.add(:store_phones, "至少包含一条信息")
    end

    if (begin_hour.to_i > end_hour.to_i) || (begin_hour.to_i == end_hour.to_i && begin_minute.to_i >= end_minute.to_i)
      self.errors.add(:begin_time, '不能大于或等于结束时间')
    end
  end

  def store_cover_name
    store_cover.try(:file).try(:filename)
  end

  def address
    "#{ChinaCity.get(province)}#{ChinaCity.get(city)}#{ChinaCity.get(area)}#{street}"
  end

  def begin_time
    "#{begin_hour}:#{begin_minute}"
  end

  def end_time
    "#{end_hour}:#{end_minute}"
  end
end
