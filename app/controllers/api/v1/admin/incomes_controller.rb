class Api::V1::Admin::IncomesController < ApiBaseController

  def yesterday_income_and_balance
    authorize! :read, VerifyCode
    yesterday_income = current_user.verify_codes.where(updated_at: Date.yesterday).sum(:income)
    balance = current_user.income
    render json: { yesterday_income: yesterday_income, balance: balance }
  end

  def the_income
    authorize! :read, VerifyCode
    income_by_date = []
    verified_codes = current_user.verify_codes.where("verify_codes.updated_at > ?", params[:date].to_date.beginning_of_day).group_by{ |verify_code| verify_code.updated_at.to_date }.sort_by{ |key, values| key }
    verified_codes.each do |date, codes|
      data = {}
      data[:date] = date
      data[:income] = codes.sum(&:income)
      income_by_date << data
    end
    render json: income_by_date.first(5)
  rescue => e
    render_error :wrong_params
  end

  def balance
    render json: { balance: current_user.income }
  end

end
