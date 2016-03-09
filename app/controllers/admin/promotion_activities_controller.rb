class Admin::PromotionActivitiesController < AdminController
  load_and_authorize_resource

  before_action :set_activity_info, only: [:new, :edit]

  def index
  end

  def create
    if @promotion_activity.save
      flash[:success] = '商家活动创建成功'
      redirect_to admin_promotion_activities_path
    else
      set_activity_info
      flash.now[:error] = "创建失败。#{@promotion_activity.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def update
    if @promotion_activity.update(promotion_activity_params)
      flash[:success] = '修改成功'
      redirect_to admin_promotion_activities_path
    else
      set_activity_info
      flash.now[:error] = "修改失败。#{@promotion_activity.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def change_status
  end

  private
  def set_activity_info
    @live_activity_info  = @promotion_activity.live_activity_info
    @share_activity_info = @promotion_activity.share_activity_info
  end

  def promotion_activity_params
    params.require(:promotion_activity)
      .permit(:user_id, activity_infos_attributes: [:id, :activity_type, :name, :price, :expiry_days, :description, :win_count, :win_rate])
  end
end
