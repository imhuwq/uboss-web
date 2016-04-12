class MenusController < ApplicationController
  include SharingResource
  before_action :authenticate_user!, except: :index
  before_action :set_store
  before_action :authenticate_user_if_browser_wechat, except: :index
  before_action :set_sharing_link_node, only: [:index]
  layout 'mobile'

  # GET /service_stores/:service_store_id/menus
  # GET /service_stores/:service_store_id/menus.json
  def index
    @q = scope.search(categories_name_eq: params[:category])
    @dishes = @q.result.includes(:categories).order("categories.position")

    c = Hash.new {|x,v| x[v] = []}
    @dishes = @dishes.reduce(c) do |h, dishe|
      dishe.categories.each do |c|
        h[c.name] << dishe
      end
      h
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def confirm
    @order = DishesOrder.new(order_params)
    @order_form = DishesOrderForm.new(@order, form_params)
  end

  def order
    @order = DishesOrder.new(order_params)
    @order_form = DishesOrderForm.new(@order, form_params)

    respond_to do |format|
      if @order_form.save
        sign_in(@order_form.buyer) if current_user.blank?
        format.html { redirect_to payments_charges_path(order_ids: @order_form.order_id, showwxpaytitle: 1) }
        format.json { render json: { url: payments_charges_path(order_ids: @order_form.order_id, showwxpaytitle: 1) }, status: 200 }
      else
        format.html { redirect_to service_store_menus_path(@store) }
        format.json   { render json: { errors: @order_form.errors.full_messages } }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      {
        seller_id: @store.user_id,
        user: current_user
      }.merge params.permit({
        order_items_attributes: [:amount, :product_inventory_id]
      })
    end

    def form_params
      params.permit(:mobile, :captcha).merge({
        sharing_code: get_seller_sharing_code(@store.user_id),
        session: session,
        seller_id: @store.user_id,
        buyer: current_user
      })
    end

    def set_store
      @store = ServiceStore.includes(:user).find params[:service_store_id]
      @seller = @store.user
    end

    def scope
      DishesProduct.published.with_store(@store).includes(:asset_img)
    end
end
