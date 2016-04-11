class TableDropJob < ActiveJob::Base
  queue_as :default

  def perform
    TableNumber.used.where("expired_at < ?", Time.now).find_each(batch_size: 500) do |table|
      table.update(status: 0, expired_at: nil)
    end
  end
end
