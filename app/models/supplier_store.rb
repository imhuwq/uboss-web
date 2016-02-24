class SupplierStore < UserInfo
  belongs_to :supplier, class_name: 'User', foreign_key: 'user_id'
  has_one :supplier_store_info, validate: true, autosave: true

  validates :store_name, presence: true
  validates :supplier_store_info, presence: true

  delegate :guess_province, :guess_province=, to: :supplier_store_info, allow_nil: true
  delegate :guess_city, :guess_city=, to: :supplier_store_info, allow_nil: true
  delegate :phone_number, :phone_number=, to: :supplier_store_info, allow_nil: true
  delegate :wechat_id, :wechat_id=, to: :supplier_store_info, allow_nil: true
end
