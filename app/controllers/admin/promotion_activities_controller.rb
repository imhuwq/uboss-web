class Admin::PromotionActivitiesController < AdminController
  load_and_authorize_resource

  before_action :set_activity_info, only: [:new, :show]

  def index
    if ["published", "unpublish"].include?(params[:type])
      @promotion_activities = @promotion_activities.try(params[:type]).includes(:user, :activity_infos).page(params[:page] || 1)
    else
      raise "invalid promotion_activities state"
    end
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

  def show
  end

  def change_status
    if params[:status] == 'published'
      @promotion_activity.status = "published"
      @notice = '上架成功'
    elsif params[:status] == 'unpublish'
      @promotion_activity.status = "unpublish"
      @notice = '取消上架成功'
    end

    if not @promotion_activity.save
      @error = model_errors(@promotion_activity).join('<br/>')
    end

    if request.xhr?
      flash.now[:success] = @notice
      flash.now[:error]   = @error
      render(partial: 'promotion_activities', locals: { promotion_activities: [@promotion_activity.reload] })
    else
      flash[:success] = @notice
      flash[:error]   = @error
      redirect_to admin_promotion_activities_path
    end
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
