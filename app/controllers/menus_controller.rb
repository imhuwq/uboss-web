class MenusController < ApplicationController
  before_action :authenticate_user!, only: [:order]
  before_action :set_store
  before_action :authenticate_user_if_browser_wechat, only: [:confirm]
  layout 'mobile'

  # GET /service_stores/:service_store_id/menus
  # GET /service_stores/:service_store_id/menus.json
  def index
    @q = scope.search(categories_name_eq: params[:category]).result
    @dishes = @q.page(params[:page])

    respond_to do |format|
      format.html
      format.json
    end
  end

  def confirm
    @order_form = DishesOrderForm.new(order_params)
  end

  def order
    @order_form = DishesOrderForm.new(order_params)

    respond_to do |format|
      if @order_form.save
        sign_in(@order_form.buyer) if current_user.blank?
        format.html { redirect_to payments_charges_path(order_ids: @order_form.order.id, showwxpaytitle: 1) }
      else
        format.html { redirect_to service_store_menus_path(@store) }
      end
      format.js
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      {
        seller_id: @store.user_id,
        buyer: current_user,
        sharing_code: get_seller_sharing_code(@store.user_id),
        session: session
      }.
      merge(params.permit(order_items_attributes: [:amount, :product_inventory_id]))
    end

    def order_item_params
      params.permit(:product_inventory_id, :amount, )
    end

    def set_store
      @store = ServiceStore.find params[:service_store_id]
    end

    def scope
      DishesProduct.published.with_store(@store)
    end
end
