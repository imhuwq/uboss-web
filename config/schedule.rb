APP_ROOT = File.expand_path(File.dirname(__FILE__)) + '/..'

set :output, "#{APP_ROOT}/log/cron.log"

every 1.day, at: "12:30am", roles: [:db] do
  runner "DailyReport.start_generate_yestoday_report"
end

every 1.day, at: "12:55am", roles: [:db] do
  runner "RongcloudJob.make_sync_history_jobs"
end

every 6.hours, roels: [:db] do
  runner "WxRefundQueryJob.perform_later"
  runner "CloseOrderJob.perform_later"
end

every 1.hours, roles: [:db] do
  runner "AutoSignOrderJob.perform_later"
end

every 1.day, at: '01:00 am', roles: [:db] do
  runner "Cooperation.perform"
end

every 1.day, at: "1:55am", roles: [:db] do
  runner "ExpiryActivityVerifyCodeJob.perform_later"
end
every 5.minutes, roles: [:db] do
  runner "TableDropJob.perform_now"
end
