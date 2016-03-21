class MenusController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :set_store

  # GET /service_stores/:service_store_id/menus
  # GET /service_stores/:service_store_id/menus.json
  def index
    @q = scope.search(categories_name_eq: params[:category]).result
    @menus = @q.page(params[:page])

    respond_to do |format|
      format.html
      format.json
    end
  end

  def confirm
    @order = DishesOrder.new(order_params)
    @order.user = current_user
    @order.seller_id = @store.user_id

    respond_to do |format|
      if @order.save
        format.html { redirect_to payments_charges_path(order_ids: @order.id, showwxpaytitle: 1) }
      else
        format.html { redirect_to service_store_menus_path(@store) }
      end
      format.js
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.permit()
    end

    def set_store
      @store = ServiceStore.find params[:service_store_id]
    end

    def scope
      DishesProduct.published.with_store(@store)
    end
end
