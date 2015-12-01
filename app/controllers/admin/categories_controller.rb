class Admin::CategoriesController < AdminController
  load_and_authorize_resource

  def index
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
      render action: :new
    else
      flash[:success] = "success"
      redirect_to action: :new
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name,:avatar)
    end
end
