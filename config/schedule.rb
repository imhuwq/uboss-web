APP_ROOT = File.expand_path(File.dirname(__FILE__)) + '/..'

set :output, "#{APP_ROOT}/log/cron.log"

every 1.day, at: "12:30am", roles: [:db] do
  runner "DailyReport.start_generate_yestoday_report"
  runner "CloseOrderJob.perform_later"
  runner "WxRefundQueryJob.perform_later"
end

