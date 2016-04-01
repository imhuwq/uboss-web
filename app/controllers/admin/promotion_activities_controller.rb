class Admin::PromotionActivitiesController < AdminController
  load_and_authorize_resource

  before_action :set_activity_info, only: [:new, :show, :edit]

  def index
    if ["published", "unpublish"].include?(params[:type])
      @promotion_activities = @promotion_activities.try(params[:type]).includes(:user, :activity_infos).page(params[:page] || 1)
    else
      flash[:error] = "invalid promotion_activities state"
      redirect_to admin_promotion_activities_path(type: 'published')
    end
  end

  def create
    @promotion_activity.status = 1
    if @promotion_activity.save
      flash[:success] = '商家活动创建成功'
      redirect_to action: :show, id: @promotion_activity.id
    else
      set_activity_info
      flash.now[:error] = "创建失败。#{@promotion_activity.errors.full_messages.join('<br/>')}"
      render :new
    end
  end

  def update
    if @promotion_activity.update(promotion_activity_update_params)
      flash[:success] = '修改成功'
      redirect_to action: :show, id: @promotion_activity.id
    else
      set_activity_info
      flash.now[:error] = "修改失败。#{@promotion_activity.errors.full_messages.join('<br/>')}"
      render :edit
    end
  end

  def change_status
    if params[:status] == 'unpublish'
      @promotion_activity.status = "unpublish"
      flash.now[:success] = '下架成功'
    end

    if not @promotion_activity.save
      flash.now[:error] = model_errors(@promotion_activity).join('<br/>')
    end

    if request.xhr?
      promotion_activities = flash.now[:error].present? ? [@promotion_activity.reload] : []
      render(partial: 'promotion_activities', locals: { promotion_activities: promotion_activities })
    else
      redirect_to admin_promotion_activities_path(type: 'published')
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

  def promotion_activity_update_params
    params.require(:promotion_activity)
      .permit(activity_infos_attributes: [:id, :win_rate])
  end
end
