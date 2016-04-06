class Admin::CallingServicesController < AdminController
  load_and_authorize_resource

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

  private

  def calling_service_params
    params.require(:calling_service).permit(:name)
  end

end
