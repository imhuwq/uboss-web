module Sellerable
  extend ActiveSupport::Concern

  included do
    def sales(segment=:all) # 销量
      scope_name = %w(today all).include?(segment) ? segment : :all
      # digest = sold_orders.have_paid.maximum(:updated_at).try(:utc).try(:to_s, :number)
      # Rails.cache.fetch("seller:sales:#{id}-#{digest}") do
        sold_orders.have_paid.send(scope_name).joins(:order_items).sum("order_items.amount") + sold_bill_orders.send(segment).count
      # end
    end

    def turnovers(segment=:all) # 营业额
      scope_name = %w(today all).include?(segment) ? segment : :all
      digest = sold_orders.have_paid.maximum(:updated_at).try(:utc).try(:to_s, :number)
      Rails.cache.fetch("seller:turnover:#{id}-#{digest}") do
        sold_orders.have_paid.send(scope_name).sum("orders.paid_amount")
      end
    end
  end
end