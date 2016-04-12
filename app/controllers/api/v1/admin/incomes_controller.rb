class Api::V1::Admin::IncomesController < ApiBaseController

  def yesterday_income_and_balance
    yesterday_income = current_user.verified_codes.where(updated_at: Date.yesterday).sum(:income)
    balance = current_user.income
    render json: { yesterday_income: yesterday_income, balance: balance }
  end

  def the_income
    income_by_date = {}
    verified_codes = current_user.verified_codes.where("verify_codes.updated_at > ?", params[:date]).group_by{ |verify_code| verify_code.updated_at.to_date }.sort_by{ |key, values| key }.reverse
    verified_codes.each do |date, codes|
      income_by_date[date] = codes.sum(&:income)
    end
    render json: income_by_date.first(5)
  rescue => e
    render_error :wrong_params
  end

  def balance
    render json: { balance: current_user.income }
  end

end
