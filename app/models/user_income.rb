class UserIncome < ActiveRecord::Base
  include Orderable
  scope :sales, -> { where(resource_type: %w(SellingIncome BillIncome )) }
end
