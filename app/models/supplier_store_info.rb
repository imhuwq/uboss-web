class SupplierStoreInfo < ActiveRecord::Base
  belongs_to :supplier_store

  validates :phone_number, format: {with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, message: '无效的手机号码'}, on: :update
end
