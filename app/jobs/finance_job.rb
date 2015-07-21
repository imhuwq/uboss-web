class FinanceJob < ActiveJob::Base

  mattr_accessor :logger

  queue_as :default

  logger ||= Logger.new(File.expand_path(File.join(Rails.root, "log/daily_reports.log"), __FILE__), 10, 1024_000)
  logger.level = Logger::INFO
  logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{severity}] #{datetime}: #{msg}\n"
  end

  def perform(date=Date.yesterday, report_type='selling')
    logger.info("START: generate report, Date: #{date}, TYPE: #{report_type}")
    begin
      __send__("generate_#{report_type}_daily_report", date)
    rescue NoMethodError
      logger.error("ERROR: method calling while generate report, Date: #{date}, TYPE: #{report_type}")
    end
    logger.info("DONE: generate report, Date: #{date}, TYPE: #{report_type}")
  end

  private

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
    report_type = DailyReport.report_types['selling']

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
        report_type: report_type,
        uniq_identify: "#{record['date']}_#{record['user_id']}_#{report_type}"
      )
    end
  end

end
