class DailyReport < ActiveRecord::Base

  include Orderable

  belongs_to :user


  #
  # selling       商家销售收入流水
  # divide        创客分成收入流水
  # sharing       分享流水(暂无)
  # user_order    商家订单付款流水
  # seller_divide 商家对应给创客的分成流水
  #
  enum report_type: {
    selling:       0,
    divide:        1,
    sharing:       2,
    user_order:    3,
    seller_divide: 4
  }

  delegate :service_rate, :store_identify, to: :user, prefix: true, allow_nil: true

  def pre_divide_income
    amount * user_service_rate / 100
  end

  def self.start_generate_yestoday_report
    FinanceJob.perform_later('order')
    FinanceJob.perform_later('selling')
    FinanceJob.perform_later('divide')
    FinanceJob.perform_later('seller_divide')
  end

  def self.insert_or_update_daily_report record
    record = record.merge(
      created_at: DateTime.now,
      updated_at: DateTime.now
    )

    columns = []
    values = record.reject {|k,v| k.to_s=='id' || v.blank? }.map do |k, v|
      columns << k
      v.respond_to?(:acts_like_time?) ? "'#{v.to_time.to_s(:db)}'" : "'#{ v }'"
    end

    ActiveRecord::Base.connection.execute <<-SQL.squish!
      WITH upsert AS
        (
          UPDATE daily_reports
          SET updated_at='#{ DateTime.now }', amount='#{ record[:amount] }'
          WHERE uniq_identify='#{ record[:uniq_identify] }'
          RETURNING *
        )
      INSERT INTO "daily_reports" (#{ columns.join(',') }) SELECT #{ values.join(',') } WHERE NOT EXISTS (SELECT * FROM upsert);
    SQL
  end

end
