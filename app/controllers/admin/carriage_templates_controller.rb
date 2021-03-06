class Admin::CarriageTemplatesController < AdminController
  include CarriageTemplatesHelper
  load_and_authorize_resource

  before_action :find_carriage, only: [:show, :edit, :update, :destroy]

  def copy
    @bak_carriage = current_user.carriage_templates.find(params[:id])
    @carriage = @bak_carriage.amoeba_dup
    name = @carriage.name.gsub(')', '\\)').gsub('(', '\\(')
    index_array = CarriageTemplate.where("name ~* ?",
                                         "#{name}\\(\\d+\\)$")\
                                  .map(&:name).grep(/#{name}\((\d+)\)/){  $1.to_i }
    index = index_array.blank? ? 1 : index_array.max + 1
    @carriage.name = @carriage.name + "(#{index})"
    @carriage.save
  end

  def index
    @carriages = current_user.carriage_templates.page(params[:page])
  end

  def edit
  end

  def destroy
   if @carriage.destroy
     flash[:success] = '删除配送模板成功'
   else
     flash[:error] = "删除配送模板失败, 原因: #{@carriage.errors.full_messages.join(';')}"
   end
    redirect_to action_to_path(:carriage_templates)
  end

  def update
    if @carriage.update(carriage_template_params)
      flash[:success] = '更新配送模板成功'
      redirect_to action_to_path(:carriage_templates)
    else
      render :edit
    end
  end

  def create
    @carriage = CarriageTemplate.new(carriage_template_params)
    if @carriage.save
      flash[:success] = '创建配送模板成功'
      redirect_to action_to_path(:carriage_templates)
    else
      render :new
    end
  end

  def new
    @carriage = CarriageTemplate.new
  end

  private
  def find_carriage
    @carriage = current_user.carriage_templates.find(params[:id])
  end

  def carriage_template_params
    params.require(:carriage_template).
      permit(
        :name,
        different_areas_attributes: [
          :id, :first_item, :carriage, :extend_item, :extend_carriage, :_destroy, region_ids: []
        ]
    ).merge(
      user_id: current_user.id
    )
  end
end
