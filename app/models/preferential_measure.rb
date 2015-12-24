class PreferentialMeasure < ActiveRecord::Base

  belongs_to :preferential_item, polymorphic: true
  belongs_to :preferential_source, polymorphic: true

  validates :amount, presence: true, money: true

  before_save :set_total_amount

  private

  def set_total_amount
    self.total_amount = self.amount
  end

end
