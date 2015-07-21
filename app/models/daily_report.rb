class DailyReport < ActiveRecord::Base

  enum report_type: { selling: 0, divide: 1, sharing: 2 }

  def self.start_generate_yestoday_report
    FinanceJob.perform_later('selling')
    FinanceJob.perform_later('divide')
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

  private

end
