APP_ROOT = File.expand_path(File.dirname(__FILE__)) + '/..'

set :output, "#{APP_ROOT}/log/cron.log"

every 1.day, at: "12:30am", roles: [:db] do
  runner "DailyReport.start_generate_yestoday_report"
  runner "CloseOrderJob.perform_later"
  runner "WxRefundQueryJob.perform_later"
end

every 1.day, at: "12:55am", roles: [:db] do
  runner "RongcloudJob.make_sync_history_jobs"
end

every 2.hours, roles: [:db] do
  runner "AutoSignOrderJob.perform_later"
end

every 1.day, at: "1:50am", roles: [:db] do
  rake "statistics:product_order"
end

every :tuesday, at: "2:50am", roles: [:db] do
  rake "statistics:count_product_sales_amount"
end
