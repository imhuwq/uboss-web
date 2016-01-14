class AgencyOrder < OrdinaryOrder
  after_create :create_purchase_order

  def create_purchase_order
    PurchaseOrder.create(order: self, seller_id: seller_id, supplier_id: 1)
  end
end
