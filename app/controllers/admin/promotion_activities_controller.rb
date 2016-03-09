class Admin::PromotionActivitiesController < AdminController

  load_and_authorize_resource

  def index
  end

  def new
    @live_activity_info = @promotion_activity.live_activity_info
    @share_activity_info = @promotion_activity.share_activity_info
  end

  def create
    @promotion_activity = PromotionActivity.new(promotion_activity_params)
    @live_activity_info = @promotion_activity.live_activity_info
    @share_activity_info = @promotion_activity.share_activity_info

    logger.info promotion_activity_params
    render :new
  end

  def update
  end

  def change_status
  end

  private
  def promotion_activity_params
    params.require(:promotion_activity).permit(:user_id, activity_infos_attributes: [:activity_type, :name, :price, :expiry_days, :description, :win_count, :win_rate])
  end
end
