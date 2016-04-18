class Api::V1::Admin::ServiceProductsController < ApiBaseController

  def index
    authorize! :read, ServiceProduct
    if %w{ published unpublish closed }.include?(params[:status])
      products = current_user.service_products.send(params[:status].to_sym)
    else
      products = current_user.service_products.available
    end
    product_infos = []
    unless products.nil?
      products.each do |product|
        product_infos << { id: product.id, product_image_url: product.image_url(:thumb), product_name: product.name, price: product.present_price, sold_amount: product.total_sells }
      end
    end
    render json: product_infos
  end

  def show
    product = ServiceProduct.find_by(id: params[:id])
    authorize! :read, product
    render json: { id: product.id, product_image_url: product.image_url(:thumb), product_name: product.name, price: product.present_price, sold_amount: product.total_sells }
  rescue => e
    render_error :wrong_params
  end

  def create
    authorize! :create, ServiceProduct
    @service_product = current_user.service_products.new(service_product_params)
    if @service_product.save
      render_model_id @service_product
    else
      render_model_errors @service_product
    end
  end

  private
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
