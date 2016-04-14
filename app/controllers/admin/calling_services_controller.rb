class Admin::CallingServicesController < AdminController
  load_and_authorize_resource
  before_action :validate_service_store_info

  def index
    @calling_services = CallingService.where(user: current_user).page(params[:page] || 1)
  end

  def create
    if @calling_service.save
      flash[:success] = '服务创建成功'
      redirect_to action: :index
    else
      flash.now[:error] = "#{@calling_service.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def update
    if @calling_service.update(calling_service_params)
      flash[:success] = '保存成功'
      redirect_to action: :index
    else
      flash.now[:error] = "保存失败。#{@calling_service.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def destroy
   if @calling_service.destroy
     flash[:success] = '删除服务成功'
   else
     flash[:error] = "删除服务失败。 #{@calling_service.errors.full_messages.join(';')}"
   end
    redirect_to action: :index
  end

  def set_table_info
    @table_info = current_user.service_store
  end

  def update_table_info
    @table_info = current_user.service_store

    begin
      ActiveRecord::Base.transaction do
        @table_info.update!(table_info_params)
        TableNumber.reset_store_table_numbers(@table_info.reload.table_count, current_user.id)
      end
    rescue => e
      @error = e
    end

    if @error.present?
      flash.now[:error] = "保存失败。#{@error}"
      render :set_table_info
    else
      flash[:success] = '保存成功'
      redirect_to action: :set_table_info
    end
  end

  private

  def calling_service_params
    params.require(:calling_service).permit(:name)
  end

  def table_info_params
    params.require(:service_store).permit(:table_count, :table_expired_in)
  end

  def validate_service_store_info
    unless current_user.service_store.try(:valid?)
      flash[:alert] = '请先完善实体店铺信息再设置服务'
      redirect_to edit_admin_service_store_path(current_user.service_store)
    end
  end

end
