class Api::V1::Admin::ProductsController < ApiBaseController

  before_action :find_product, only: [:show, :inventories, :detail]

  def index
    authorize! :read, Product
    @products = append_default_filter current_user.ordinary_products.available, order_column: :updated_at
  end

  def create
    authorize! :create, Product
    @product = current_user.ordinary_products.new(product_params)
    if @product.save
      render_model_id @product
    else
      render_model_errors @product
    end
  end

  def show
    authorize! :read, Product
  end

  def detail
    authorize! :read, Product
  end

  def inventories
    authorize! :read, Product
    @product_inventories = @product.seling_inventories
  end

  def change_status
    authorize! :update, @product
    if params[:status] == 'published'
      @product.status = "published"
    elsif params[:status] == 'unpublish'
      @product.status = 'unpublish'
    elsif params[:status] == 'closed'
      @product.status = 'closed'
    end

    if @product.save
      render_model_id @product
    else
      render_model_errors @product
    end
  end

  private

  def find_product
    @product = current_user.ordinary_products.available.find(params[:id])
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
