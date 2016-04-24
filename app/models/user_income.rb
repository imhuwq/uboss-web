class UserIncome < ActiveRecord::Base
  include Orderable
  belongs_to :resource, polymorphic: true
  scope :sales, -> { where(resource_type: %w(SellingIncome BillIncome )) }
end
