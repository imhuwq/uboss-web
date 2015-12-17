class Admin::CategoriesController < AdminController
  load_and_authorize_resource

  def index
    @categories = current_user.categories.order('updated_at DESC')
  end

  def new
  end

  def edit
  end

  def create
    if @category.save
      redirect_to admin_categories_url, notice: "分组#{@category.name}创建成功"
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_url, notice: "成功更新分组#{@category.name}"
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_url, notice: '成功删除分组'
  end

  def update_categories
    begin
      params[:categories].each do |i,attributes|
        Category.find_by(id: attributes[:id]).update(attributes.permit(:name, :avatar))
      end
    rescue Exception => ex
      @errors << ex.full_message
    end
    if @errors
      flash[:errors] = @errors.join('\n')
      render action: :index
    else
      flash[:success] = "success"
      redirect_to action: :index
    end
  end

  def updata_category_img
    category = Category.find(params[:id])
    if category.update(avatar: params[:avatar])
      @message = {message: "上传成功！"}
    else
      @message = {message:"上传失败"}
    end
    render json:  @message
  end

  def update_category_name
    category = current_user.categories.find(params[:id])
    if category.update(name: params[:name])
      @message = {message: "修改成功！"}
    else
      @message = {message:"修改失败"}
    end
    render json:  @message
  end

  def change_category_img
    category = Category.find(params[:id])
    if category.image_url
      render json:  {url: category.image_url}.to_json
    else
      render json: {}.to_json
    end
    
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name,:avatar)
    end
end
