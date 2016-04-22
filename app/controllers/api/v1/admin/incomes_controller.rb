class Api::V1::Admin::IncomesController < ApiBaseController

  def yesterday_income_and_balance
    authorize! :read, VerifyCode
    yesterday_income = current_user.verify_codes.where(updated_at: Date.yesterday).sum(:income)
    balance = current_user.income
    render json: { data: { yesterday_income: yesterday_income, balance: balance } }
  end

  def income_by_day
    authorize! :read, VerifyCode
    income_by_date = []
    verified_codes = current_user.verify_codes.where("verify_codes.updated_at between ? and ?", params[:date].to_date.beginning_of_month.beginning_of_day, params[:date].to_date.end_of_month.end_of_day).group_by{ |verify_code| verify_code.updated_at.to_date }.sort_by{ |key, values| key }
    verified_codes.each do |date, codes|
      data = {}
      data[:date] = date
      data[:income] = codes.sum(&:income)
      income_by_date << data
    end
    render json: { data: income_by_date }
  rescue => e
    render_error :wrong_params
  end

  def income_by_month
    authorize! :read, VerifyCode
    income_by_month = []
    verified_codes = current_user.verify_codes.where("verify_codes.updated_at between ? and ?", params[:date].to_date.beginning_of_year.beginning_of_day, params[:date].to_date.end_of_year.end_of_day).group_by{ |verify_code| verify_code.updated_at.month }.sort_by{ |key, values| key }
    verified_codes.each do |month, codes|
      data = {}
      data[:month] = month.to_s
      data[:income] = codes.sum(&:income)
      income_by_month << data
    end
    render json: { data: income_by_month }
  rescue => e
    render_error :wrong_params
  end

  def balance
    render json: { data: { balance: current_user.income } }
  end

end
