class Admin::StoresController < AdminController
  def edit
    @advertisements = get_advertisements
    @categories = Category.where(use_in_store: true, user_id: current_user.id).order('use_in_store_at')
    @select_categories = Category.where(use_in_store: false, user_id: current_user.id)
  end

  def update_store_cover
    if current_user.update(store_cover: params[:avatar])
      @message = { message: '上传成功！' }
    else
      @message = { message: '上传失败' }
    end
    render json:  @message
  end

  def update_advertisement_img
    adv = Advertisement.find_by!(id: params[:resource_id], user_id: current_user.id, user_type: 'Ordinary')
    if adv && adv.update(avatar: params[:avatar])
      @message = { message: '上传成功！' }
    else
      @message = { message: '上传失败' }
    end
    render json:  @message
  end

  def update_advertisement_order
    adv = Advertisement.find_by!(id: params[:resource_id], user_id: current_user.id, user_type: 'Ordinary')
    if adv && adv.update(order_number: params[:resource_val])
      @message = { message: '上传成功！' }
    else
      @message = { message: '上传失败' }
    end
    render json:  @message
  end

  def get_advertisement_items
    if params[:type] == 'product'
      arr = []
      (current_user.products.published.select(:name, :id).all - current_user.products.published.joins(:advertisements).select(:name, :id)).each do |p|
        arr += [{ id: p.id, text: p.name }]
      end
      render json: { products: arr }
    elsif params[:type] == 'category'
      arr = []
      (current_user.categories.select(:name, :id).all - current_user.categories.joins(:advertisements).select(:name, :id)).each do |c|
        arr += [{ id: c.id, text: c.name }]
      end
      render json: { categories: arr }
    end
  end

  def create_advertisement
    if params[:advertisement]
      @adv = Advertisement.new(params.require(:advertisement).permit(:avatar, :order_number))
      @adv.platform_advertisement = false
      @adv.user_id = current_user.id
      @adv.user_type = 'Ordinary'
      if params[:advertisement][:type] == 'product' && product = current_user.products.find_by_id(params[:advertisement][:id])
        @adv.product_id = product.id
      elsif params[:advertisement][:type] == 'category' && category = current_user.categories.find_by_id(params[:advertisement][:id])
        @adv.category_id = category.id
      end
      if @adv.save
        flash.now[:success] = '创建成功'
      else
        @adv.valid?
        flash.now[:error] = "#{@adv.errors.full_messages.join('<br/>')}"
      end
    end
    @advertisements = get_advertisements
  end

  def add_category
    category = Category.where(use_in_store: false).find_by!(id: params[:category][:id], user_id: current_user.id)
    if category && params[:category][:avatar] == ''
      category.update(use_in_store: true, use_in_store_at: Time.now)
    elsif category
      category.update(use_in_store: true, use_in_store_at: Time.now, avatar: params.require(:category).permit(:avatar, :order_number)[:avatar])
    end
    @categories = Category.where(use_in_store: true, user_id: current_user.id).order('use_in_store_at')
    @select_categories = Category.where(use_in_store: false, user_id: current_user.id)
  end

  def remove_advertisement_item
    adv = Advertisement.find_by!(id: params[:resource_id], user_id: current_user.id, user_type: 'Ordinary')
    if adv && adv.destroy
      flash.now[:success] = '删除成功'
    else
      flash.now[:error] = '删除失败'
    end
    @advertisements = get_advertisements
    render 'create_advertisement'
  end

  def remove_category_item
    category = Category.find_by!(id: params[:id], user_id: current_user.id)
    if category && category.update(use_in_store: false)
      flash.now[:success] = '移除成功'
    else
      flash.now[:error] = '移除失败'
    end
    @categories = Category.where(use_in_store: true, user_id: current_user.id).order('use_in_store_at')
    @select_categories = Category.where(use_in_store: false, user_id: current_user.id)
    render 'add_category'
  end

  def update_store_name
    duplication_name = UserInfo.find_by(store_name: params[:resource_val]) if params[:resource_val] != ''
    if (!duplication_name.present? || duplication_name.try(:user_id) == current_user.id) && current_user.update(store_name: params[:resource_val])
      @message = { success: '修改成功！' }
    else
      @message = { error: "修改失败#{duplication_name.present? ? ',此名称已经有人使用。' : ''}" }
    end
    render json:  @message
  end

  def update_store_short_description
    if current_user.update(store_short_description: params[:resource_val])
      @message = { message: '修改成功！' }
    else
      @message = { message: '修改失败' }
    end
    render json:  @message
  end

  def remove_advertisement
    case params[:resource_type]
    when 'product'
      product = current_user.products.find(params[:resource_id])
      if product.update(show_advertisement: false)
        @message = { success: '修改成功' }
      else
        @message = { error: '修改失败' }
      end
    when 'category'
      category = current_user.categories.find(params[:resource_id])
      if category.update(show_advertisement: false)
        @message = { success: '修改成功' }
      else
        @message = { error: '修改失败' }
      end
    end
    render json: @message.to_json
  end

  def get_category_img
    if @category = current_user.categories.find(params[:resource_id])
      @update_image_url = "admin/categories/#{@category.id}/update_category_img"
      if @category.asset_img.avatar.current_path
        avatar_identifier = @category.asset_img.avatar_identifier
        image_url = @category.image_url
      else
        avatar_identifier = ''
        image_url = '/assets/admin/no-img-400x400.png'
      end
      @message = { message: '获取成功！', image_url: image_url, avatar_identifier: avatar_identifier }
    else
      @message = { message: '获取失败' }
    end
    render json:  @message
  end

  private

  def get_advertisements
    Advertisement.joins('left join products on (products.id = advertisements.product_id)')
      .where('(product_id is not null AND products.status = 1) OR product_id is null')
      .where(user_id: current_user.id, platform_advertisement: false, user_type: 'Ordinary')
      .order('order_number')
  end
end
