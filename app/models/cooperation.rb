class Cooperation < ActiveRecord::Base
  belongs_to :supplier, class_name: 'User'
  belongs_to :agency, class_name: 'User'
  validates :supplier_id, presence: true
  validates :agency_id, presence: true

  def adjust(quantity, date=Date.today)
    case date
    when Date.today
      # self.tday_performance += quantity
    when Date.yesterday
      self.yday_performance += quantity
    end
    self.total_performance += quantity
  end

  def self.perform
    segment = Date.yesterday
    PurchaseOrder.today(segment).with_payed.group(:supplier_id, :seller_id).sum("pay_amount").each do |(supplier_id, seller_id), amount|
      cooperation = where(supplier_id: supplier_id, agency_id: seller_id).first
      cooperation.adjust(amount, segment)
      cooperation.save
    end
  end
end
