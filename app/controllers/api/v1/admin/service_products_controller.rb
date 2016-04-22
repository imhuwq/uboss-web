class Api::V1::Admin::ServiceProductsController < ApiBaseController

  before_action :set_service_product, only: [:show, :change_status]

  def index
    authorize! :read, ServiceProduct
    if %w{ published unpublish}.include?(params[:status])
      products = current_user.service_products.send(params[:status].to_sym)
    elsif params[:status] == "neverpublish"
      products = current_user.service_products.select{ |s| s.created_at == s.updated_at }
    else
      products = current_user.service_products.available
    end
    product_infos = []
    unless products.nil?
      products.each do |product|
        product_infos << { id: product.id, product_image_url: product.image_url(:thumb), product_name: product.name, product_created_at: product.created_at, price: product.present_price, sold_amount: product.total_sells }
      end
    end
    render json: { data: product_infos }
  end

  def show
    authorize! :read, @service_product
    render json: { data: { id: @service_product.id, product_image_url: @service_product.image_url(:thumb), product_name: @service_product.name, product_created_at: @service_product.created_at, price: @service_product.present_price, sold_amount: @service_product.total_sells } }
  rescue => e
    render_error :wrong_params
  end

  def create
    authorize! :create, ServiceProduct
    @service_product = current_user.service_products.new(service_product_params)
    if @service_product.save
      render json: { data: {} }
    else
      render_model_errors @service_product
    end
  end

  def change_status
    authorize! :update, @service_product
    if %w{ published unpublish}.include?(params[:status])
      if @service_product.send((params[:status]+"!").to_sym)
        render json: { data: {} }
      else
        render_model_errors @service_product
      end
    else
      render_error :wrong_params
    end
  end

  private

  def set_service_product
    @service_product = current_user.service_products.available.find_by(id: params[:id])
  end

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def service_product_params
    params.permit(
      :name,  :service_type, :original_price, :present_price,
      :count, :avatar, :content, :monthes,
      :short_description, :purchase_note,
      product_inventories_attributes: [
        :id, :price, :count,
        :share_amount_total, :privilege_amount, :share_amount_lv_1,
        sku_attributes: product_propertys_params[:product_propertys_names],
      ]
    )
  end
end
