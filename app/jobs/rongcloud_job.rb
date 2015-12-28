class RongcloudJob < ActiveJob::Base

  include Loggerable

  queue_as :default

  attr_reader :user, :rong_messager

  HISTORY_SYNC_TASK_QUEUE = 'uboss:jobs:synrc_his'

  def perform(options = {})
    case options[:type]
    when 'user_info'
      @user = options[:user]
      sync_user_info
    when 'sync_history'
      @rong_messager = Rongcloud::Service::Message.new
      sync_history
    end
  end

  def self.make_sync_history_jobs(date = Date.yesterday)
    logger.info "Start making sync Rongcloud histroys, Date: #{date}"

    $redis.del HISTORY_SYNC_TASK_QUEUE
    ('00'..'23').to_a.each do |hour|
      $redis.rpush HISTORY_SYNC_TASK_QUEUE, { time: "#{date.strftime('%Y%m%d')}#{hour}" }.to_json
    end
    self.perform_later(type: 'sync_history')
  end

  private

  def sync_history
    while task = $redis.lpop(HISTORY_SYNC_TASK_QUEUE)
      begin
        task = JSON.parse(task).symbolize_keys
        history = rong_messager.history task[:time]
        logger.info "Get Rongcloud histroys, Time: #{task[:time]}"
        raise 'test' if task[:time] == '2015112521'
        raise 'test' if task[:time] == '2015112522'

        if history[:code] == 200 && history[:url] && history[:url].include?('http')
          system("curl -o log/chat_histories/#{history[:date]}.zip #{history[:url]}")
          #system("unzip -o tmp/#{history[:date]}.zip -d log/chat_histories/ && rm tmp/#{history[:date]}.zip")
        end
        history[:code] # => true
      rescue => exception
        task[:count] ||= 1
        logger.error "Process Rongcloud histroys FAIL, Time: #{task[:time]}, Reinsert job count: #{task[:count]}"
        raise exception if task[:count].present? && task[:count] > 1
        $redis.rpush HISTORY_SYNC_TASK_QUEUE, { time: task[:time], count: task[:count] + 1 }.to_json
      end
    end
  end

  def sync_user_info
    if user.rongcloud_token.blank?
      user.find_or_create_rongcloud_token
    else
      rong_user = Rongcloud::Service::User.new

      rong_user.user_id      = user.id
      rong_user.name         = user.identify
      rong_user.portrait_uri = user.avatar_url(:thumb)

      rong_user.refresh
    end
  end

end
