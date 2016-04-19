class Admin::CategoriesController < AdminController
  load_and_authorize_resource

  def index
    @dishes = params[:dishes]
    if @dishes == 'true'
      @categories = current_user.categories.dishes_categories.includes(:products)
      @has_many_categories = except_other_has_many_categories
    else
      @categories = current_user.categories.electricity_categories.includes(:products)
    end
  end

  def sort
    @dishes = params[:dishes]
    if params[:opt] == 'up'
      @category.move_higher
    else
      @category.move_lower
    end
    @categories = current_user.categories.dishes_categories.includes(:products)
    @has_many_categories = except_other_has_many_categories
  end

  def new
    @dishes = params[:dishes]
  end

  def edit
    @dishes = params[:dishes]
  end

  def create
    @dishes = params[:dishes]
    if @dishes == "true"
      @category.store_id = current_user.service_store.id
      @category.store_type = current_user.service_store.class.name
    else
      @category.store_id = current_user.ordinary_store.id
      @category.store_type = current_user.ordinary_store.class.name
    end
    if @category.save
      @category.update(position: nil) if @dishes == "false"
      redirect_to admin_categories_url(dishes: @dishes), notice: "分组#{@category.name}创建成功"
    else
      render :new
    end
  end

  def update
    @dishes = params[:dishes]
    if @category.update(category_params)
      Category.find_by(name: '其他', user_id: @category.user_id).try(:move_to_bottom) if @category.store_type == 'ServiceStore'
      redirect_to admin_categories_url(dishes: @dishes), notice: "成功更新分组#{@category.name}"
    else
      render :edit
    end
  end

  def destroy
    @dishes = params[:dishes]
    @category.destroy
    redirect_to admin_categories_url(dishes: @dishes), notice: '成功删除分组'
  end

  def update_category_img
    category = Category.find(params[:resource_id])
    if category.update(avatar: params[:avatar])
      @message = {message: "上传成功！", id: category.id}
    else
      @message = {message:"上传失败"}
    end
    render json:  @message
  end

  def update_category_name
    category = current_user.categories.find(params[:id])

    if category.update(name: params[:resource_val])
      @message = {success: "修改成功！"}
    else
      @message = {error:"修改失败: #{category.errors.full_messages.join('<br/>')}"}
    end
    render json:  @message.to_json
  end


  private
  def except_other_has_many_categories
    !(@categories.where(name: '其他').present? && @categories.count == 2)
  end
    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      if params[:category][:position].present?
        params.require(:category).permit(:name,:avatar, :position)
      else
        params.require(:category).permit(:name,:avatar)
      end
    end
end
