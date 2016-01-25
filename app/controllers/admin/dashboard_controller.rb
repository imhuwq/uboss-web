class Admin::DashboardController < AdminController

  def index
    binding.pry
    @unship_orders = current_user.sold_ordinary_orders.payed.includes(:user).limit(10)
    @sellers = current_user.sellers.unauthenticated_seller_identify.limit(10)
    @official_agent_product = OrdinaryProduct.official_agent
    @unship_amount = current_user.sold_ordinary_orders.payed.count
    @today_selled_amount = current_user.sold_orders.today.count
    @total_history_income = current_user.transactions.sum(:adjust_amount)
    hash = JSON.parse RestClient.get( "http://ip.taobao.com/service/getIpInfo.php?ip=#{request.remote_ip}")
    hash[:data][:city]
    hash[:data][:city_id]
    get_expect_income
  end

  def backend_status
  end

  private
    def get_expect_income
      @expect_income = 0
      if current_user.is_seller?
        @expect_income += current_user.sold_ordinary_orders.shiped.sum(:pay_amount) * 0.90
      end
      if current_user.is_agent?
        @expect_income += current_user.seller_ordinary_orders.shiped.sum(:pay_amount) * 0.05
      end
    end

end
