class RecommendsController < ApplicationController
  before_action :authenticate_user!

  def create
    @recommend = Recommend.new(user_id: current_user.id, recommended_id: params[:recommended_id], recommended_type: params[:recommended_type])
    if @recommend.save
      render json: { status: 'ok', message: '操作成功' }
    else
      render json: { status: "failure", error: "操作错误，请刷新再尝试" }
    end
  end

  def destroy
    @recommend = Recommend.where(user_id: current_user.id, recommended_id: params[:recommended_id], recommended_type: params[:recommended_type]).first
    if @recommend.destroy
      render json: { status: 'ok', message: '操作成功' }
    else
      render json: { status: "failure", error: "操作错误，请刷新再尝试" }
    end
  end
end
