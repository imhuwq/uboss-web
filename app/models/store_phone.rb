class StorePhone < ActiveRecord::Base
  belongs_to :service_store

  validates :phone_number, length: { is: 11 }, format: {with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, message: '无效的手机号码'}, if: "phone_number.present?"

  validate do
    if fixed_line.blank? && phone_number.blank?
      self.errors.add(:fixed_line_or_phone_number, "不能为空")
    end
  end

  def fixed_phone
    "#{area_code}-#{fixed_line}"
  end
end
