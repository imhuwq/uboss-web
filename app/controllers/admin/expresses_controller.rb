class Admin::ExpressesController < AdminController
  before_action :find_express, only: [:edit, :show, :update, :set_common, :cancel_common]

  def set_common
    authorize! :set_common, @express
    user = current_user
    user.expresses.push(@express) unless user.expresses.exists?(@express)
    if user.save
      flash[:success] = '设置成功'
    else
      flash[:error] = '设置失败'
    end
    redirect_to admin_expresses_path
  end

  def cancel_common
    authorize! :set_common, @express
    user = current_user
    user.expresses.destroy(@express) if user.expresses.exists?(@express)
    if user.save
      flash[:success] = '取消成功'
    else
      flash[:error] = '取消失败'
    end
    redirect_to admin_expresses_path
  end

  def index
    authorize! :read, Express
    @expresses = Express.where(private_id: [nil, current_user.id]).page(params[:page])
  end

  def new
    authorize! :create, Express
    @express = Express.new
  end

  def edit
    authorize! :update, Express
  end

  def update
    authorize! :update, @express
    if @express.update(express_params)
      flash[:success] = '更新成功'
      redirect_to admin_expresses_path
    else
      render :edit
    end
  end

  def create
    authorize! :create, @express
    @express = Express.new(express_params)
    if @express.save
      flash[:success] = '创建成功'
      redirect_to admin_expresses_path
    else
      render :new
    end
  end

  private
  def find_express
    @express = Express.find(params[:id])
  end

  def express_params
    params.require(:express).permit(:name)
  end
end
