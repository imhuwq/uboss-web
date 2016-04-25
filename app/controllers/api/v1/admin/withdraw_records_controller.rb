class Api::V1::Admin::WithdrawRecordsController < ApiBaseController

  def index
    authorize! :read, WithdrawRecord
    withdraw_infos = []
    withdraw_records = current_user.withdraw_records.order("created_at DESC")
    unless withdraw_records.nil?
      withdraw_records.each do |wd|
        bank_card_number = if wd.bank_info.present?
                                       wd.bank_info[:number]
                                     elsif wd.bank_card.present?
                                       wd.bank_card.number
                                     else
                                       nil
                                     end
        withdraw_infos << { amount: wd.amount, bank_card_number: bank_card_number, bank_card_id: wd.bank_card.try(:id), created_at: wd.created_at, state: wd.state_i18n }
      end
    end
    render json: { data: withdraw_infos }
  end

  def create 
    authorize! :create, WithdrawRecord
    @withdraw_record = current_user.withdraw_records.build(withdraw_record_params)
    if @withdraw_record.save
      render json: { data: { id: @withdraw_record.id } }
    else
      render_model_errors @withdraw_record
    end
  end

  private

  def withdraw_record_params
    params.permit(:bank_card_id, :amount)
  end

end
