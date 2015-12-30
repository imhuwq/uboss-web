class FillUserConfirmedAt < ActiveRecord::Migration
  def up
    say_with_time 'FillUserConfirmedAt' do
      User.update_all(confirmed_at: Time.now)
    end
  end

  def down
  end
end
