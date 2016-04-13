class BillOrderDivideJob < ActiveJob::Base

  include Loggerable

  class OrderNotPayed < StandardError; ;end

  PLATFORM_BILL_RATE = 0.0078

  queue_as :orders

  def perform(bill_order)
    if not bill_order.reload.payed?
      raise OrderNotPayed, "BillOrder Not payed, state: #{bill_order.state}"
    end

    paid_amount = bill_order.paid_amount

    official_divide_income = (paid_amount * PLATFORM_BILL_RATE).truncate(2)
    seller_bill_income = paid_amount - official_divide_income

    ActiveRecord::Base.transaction do
      bill_income = BillIncome.create!(
        user: bill_order.seller,
        amount: seller_bill_income,
        bill_order: bill_order
      )
      logger.info(
        "Divide bill order: #{bill_order.number}, [BillIncome id: #{bill_income.id}, amount: #{seller_bill_income} ]")
      divide_record = DivideIncome.create!(
        bill_order: bill_order,
        amount: official_divide_income,
        user: User.official_account
      )
      logger.info(
        "Divide bill order: #{bill_order.number}, [OAgent id: #{divide_record.id}, amount: #{official_divide_income} ]")
    end
  end
end
