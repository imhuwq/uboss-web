class Api::V1::WithdrawRecordsController < ApiBaseController

  def index
    withdraw_infos = [] 
    withdraw_records = current_user.withdraw_records
    unless withdraw_records.nil?
      withdraw_records.each do |wd|
        withdraw_infos << { amount: wd.amount, bank_card_last_four_number: wd.bank_info[:number].last(4), created_at: wd.created_at, state_i18n: wd.state_i18n }
      end
    end
    render json: withdraw_infos
  end

  def create 
    @withdraw_record = current_user.withdraw_records.build(withdraw_record_params)
    if @withdraw_record.save
      head(200)
    else
      render_model_errors @withdraw_record
    end
  end

  private

  def bank_card_params
    params.permit(:bank_card_id, :amount)
  end

end
