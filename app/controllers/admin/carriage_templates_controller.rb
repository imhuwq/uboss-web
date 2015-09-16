class Admin::CarriageTemplatesController < AdminController
  before_action :find_carriage, only: [:show, :edit, :update, :destroy]

  def index
    @carriages = CarriageTemplate.all
  end

  def edit
  end

  def destroy
   if @carriage.destroy
     flash[:success] = '删除配送模板成功'
   else
     flash[:error] = '删除配送模板失败'
   end
    redirect_to admin_carriage_templates_path
  end

  def update
    if @carriage.update(carriage_template_params)
      flash[:success] = '更新配送模板成功'
      redirect_to admin_carriage_templates_path
    else
      render :edit
    end
  end

  def create
    @carriage = CarriageTemplate.new(carriage_template_params)
    if @carriage.save
      flash[:success] = '创建配送模板成功'
      redirect_to admin_carriage_templates_path
    else
      render :new
    end
  end

  def new
    @carriage = CarriageTemplate.new
  end

  private
  def find_carriage
    @carriage = CarriageTemplate.find(params[:id])
  end

  def carriage_template_params
    params.require(:carriage_template).permit(:name, different_areas_attributes: [:id, :first_item, :carriage, :extend_item, :extend_carriage, :_destroy, region_ids: [] ])
  end
end
