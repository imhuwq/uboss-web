class Admin::RefundReasonsController < AdminController
  before_action :find_refund_reason, only: [:edit, :update, :destroy]

  def new
    @reason = RefundReason.new
  end

  def edit
  end

  def create
    @reason = RefundReason.new(reason_params)
    if @reason.save
      flash[:success] = '创建成功'
      redirect_to admin_refund_reasons_path
    else
      render :new
    end
  end

  def index
    @reasons = RefundReason.all.page(params[:page])
  end

  def update
    if @reason.update(reason_params)
      flash[:notice] = '更新成功'
      redirect_to admin_refund_reasons_path
    else
      flash.now[:error] = '更新失败'
      render :edit
    end
  end

  def destroy
    if @reason.destroy
      flash[:notice] = '删除成功'
    else
      flash[:error] = '删除失败'
    end
    redirect_to admin_refund_reasons_path
  end

  private
  def find_refund_reason
    @reason = RefundReason.find(params[:id])
  end

  def reason_params
    params.require(:refund_reason).permit(:reason)
  end
end
