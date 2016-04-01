module PromotionActivitiesHelper
  def translate_activity_type(activity_type)
    activity_type == "live" ? "现场活动" : "分享活动"
  end
end
