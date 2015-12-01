class Api::V1::Admin::ProductsController < ApiBaseController

  before_action :find_product, only: [:show, :inventories, :detail]

  def index
    @products = append_default_filter current_user.products.available, order_column: :updated_at
  end

  def create
    authorize! :create, Product
    @product = current_user.products.new(product_params)
    if @product.save
      render_model_id @product
    else
      render_model_errors @product
    end
  end

  def show
  end

  def detail
  end

  def inventories
    @product_inventories = @product.seling_inventories
  end

  private

  def find_product
    @product = current_user.products.available.find(params[:id])
  end

  def product_propertys_params
    params.permit(product_propertys_names: [])
  end

  def product_params
    params.permit(
      :name,      :original_price,  :present_price,     :count,
      :content,   :has_share_lv,    :calculate_way,     :avatar,
      :buyer_pay, :traffic_expense, :short_description, :transportation_way,
      :carriage_template_id, :status, content_images: [],
      product_inventories_attributes: [
        :id, :price, :count, :share_amount_total, :privilege_amount,
        :share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3,
        sku_attributes: product_propertys_params[:product_propertys_names],
      ]
    )
  end

end
