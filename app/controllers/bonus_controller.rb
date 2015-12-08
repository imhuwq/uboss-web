class BonusController < ApplicationController

  def create
    @user = User.find_or_create_guest(params.fetch(:mobile))
    @bonus_record = BonusRecord.new(params.permit(:amount))
    @bonus_record.user = @user
    if @bonus_record.save
      head(200)
    else
      render json: { message: model_errors(@bonus_record) }, status: 422
    end
  end

end
