class Admin::PurchaseOrdersController < AdminController
  load_and_authorize_resource
  before_action :set_purchase_order, only: [:delivery]

  def index
    @scope = scope
    @purchase_orders = @scope.page(params[:page])
  end

  def delivery
  end

  private
  def set_purchase_order
    @purchase_order = scope.find params[:id]
  end
  
  def scope
    PurchaseOrder.accessible_by(current_ability)
  end
end
