class BonusController < ApplicationController

  before_action :set_user_form_mobile

  def create
    @bonus_record = Ubonus::Game.new(params.permit(:amount))
    @bonus_record.user = @user
    if @bonus_record.save
      head(200)
    else
      render json: { message: model_errors(@bonus_record) }, status: 422
    end
  end

  def invited
    if @user.received_invite_bonus?
      return render json: { message: 'received' }, status: 422
    end
    @bonus_record = Ubonus::Invite.new(
      amount: session[Ubonus::Invite::RAND_BONUS_SESSIONS_KEY],
      user: @user,
      inviter_uid: params[:inviter_uid]
    )
    if @bonus_record.save
      session[Ubonus::Invite::RAND_BONUS_SESSIONS_KEY] = nil
      render json: {
        amount: @bonus_record.amount,
        invite_url: bonus_invite_pages_url(inviter_uid: CryptService.encrypt(@user.id))
      }
    else
      render json: { message: model_errors(@bonus_record) }, status: 422
    end
  end

  private

  def set_user_form_mobile
    @user = User.find_or_create_guest(params.fetch(:mobile))
    if !@user.persisted?
      return render json: { message: model_errors(@user) }, status: 422
    end
  end

end
