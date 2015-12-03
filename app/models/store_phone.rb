class StorePhone < ActiveRecord::Base
  belongs_to :service_store

  validate do
    if fixed_line.blank? && phone_number.blank?
      self.errors.add(:fixed_line_or_phone_number, "不能为空")
    end
  end

  def fixed_phone
    "#{area_code}-#{fixed_line}"
  end
end
