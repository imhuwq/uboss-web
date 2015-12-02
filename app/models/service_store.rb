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
  end
end
