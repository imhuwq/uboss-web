class Admin::CarriageTemplatesController < AdminController
  load_and_authorize_resource

  before_action :find_carriage, only: [:show, :edit, :update, :destroy]

  def copy
    @bak_carriage = CarriageTemplate.find(params[:id])
    @carriage = @bak_carriage.amoeba_dup
    name = @carriage.name.gsub(')', '\\)').gsub('(', '\\(')
    last_copy_name = CarriageTemplate.where("name ~* ?",
                                            "#{name}\\(\\d+\\)$")\
                                      .reorder('created_at desc').first.try(:name).to_s
    reg_result = last_copy_name.match(/\((\d+)\)$/)
    index = (reg_result.blank? ? nil : reg_result[1].to_i + 1) || '1'
    @carriage.name = @carriage.name + "(#{index.to_s})"
    @carriage.save
  end

  def index
    @carriages = CarriageTemplate.all.page(params[:page])
  end

  def edit
  end

  def destroy
   if @carriage.destroy
     flash[:success] = '删除配送模板成功'
   else
     flash[:error] = "删除配送模板失败, 原因: #{@carriage.errors.full_messages.join(';')}"
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
