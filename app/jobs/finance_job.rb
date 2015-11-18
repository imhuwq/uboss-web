class FinanceJob < ActiveJob::Base

  include Loggerable

  queue_as :default

  def perform(report_type='selling', date=Date.yesterday)

    date = date.acts_like?(:string) ? Date.parse(date) : date

    logger.info("START: generate report, Date: #{date}, TYPE: #{report_type}")
    begin
      __send__("generate_#{report_type}_daily_report", date)
    rescue NoMethodError
      logger.error("ERROR: method calling while generate report, Date: #{date}, TYPE: #{report_type}")
    end
    logger.info("DONE: generate report, Date: #{date}, TYPE: #{report_type}")
  end

  private

  def generate_seller_divide_daily_report(date)
    report_type = DailyReport.report_types['seller_divide']

    result = ActiveRecord::Base.connection.execute <<-SQL.squish!
      SELECT divide_incomes.user_id AS user_id,
        orders.seller_id AS seller_id,
        SUM(amount) AS total_amount,
        DATE(divide_incomes.created_at) AS date
      FROM divide_incomes
      INNER JOIN orders ON orders.id = divide_incomes.order_id
      WHERE divide_incomes.created_at > '#{date}' AND divide_incomes.created_at < '#{date + 1.day}'
      GROUP BY date, divide_incomes.user_id, orders.seller_id
    SQL

    batch_insert(result, report_type)
  end

  def generate_order_daily_report(date)
    report_type = DailyReport.report_types['user_order']
    result = ActiveRecord::Base.connection.execute <<-SQL.squish!
      SELECT orders.seller_id AS user_id, SUM(pay_amount) AS total_amount, DATE(orders.signed_at) AS date
      FROM orders
      WHERE orders.signed_at > '#{date}' AND orders.signed_at < '#{date + 1.day}'
      GROUP BY date, orders.seller_id
    SQL

    batch_insert(result, report_type)
  end

  def generate_selling_daily_report(date)
    report_type = DailyReport.report_types['selling']

    result = ActiveRecord::Base.connection.execute <<-SQL.squish!
      SELECT user_id, SUM(amount) AS total_amount, DATE(created_at) AS date
      FROM selling_incomes
      WHERE created_at > '#{date}' AND created_at < '#{date + 1.day}'
      GROUP BY date, user_id
    SQL

    batch_insert(result, report_type)
  end

  def generate_divide_daily_report(date)
    report_type = DailyReport.report_types['divide']

    result = ActiveRecord::Base.connection.execute <<-SQL.squish!
      SELECT user_id, SUM(amount) AS total_amount, DATE(created_at) AS date
      FROM divide_incomes
      WHERE created_at > '#{date}' AND created_at < '#{date + 1.day}'
      GROUP BY date, user_id
    SQL

    batch_insert(result, report_type)
  end

  def batch_insert(result, report_type)
    result.to_a.each do |record|
      DailyReport.insert_or_update_daily_report(
        day: record['date'],
        amount: record['total_amount'],
        user_id: record['user_id'],
        seller_id: record['seller_id'],
        report_type: report_type,
        uniq_identify: "#{record['date']}_#{record['user_id']}_#{report_type}_#{record['seller_id']}"
      )
    end
  end

end
