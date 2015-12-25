module Sellerable
  extend ActiveSupport::Concern

  included do
    def sales
      digest = sold_orders.have_paid.maximum(:updated_at).try(:utc).try(:to_s, :number)
      Rails.cache.fetch("seller:sales:#{id}-#{digest}") do
        sold_orders.have_paid.joins(:order_items).sum("order_items.amount")
      end
    end

    def turnovers
      digest = sold_orders.have_paid.maximum(:updated_at).try(:utc).try(:to_s, :number)
      Rails.cache.fetch("seller:turnover:#{id}-#{digest}") do
        sold_orders.have_paid.sum("orders.paid_amount")
      end
    end
  end
end