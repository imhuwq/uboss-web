class DateFromUserInfoToOrdinaryStore < ActiveRecord::Migration
  def change
    UserInfo.all.each do |user_info|
      if user_info.type.nil?
        user_info.update(type: 'OrdinaryStore')
      end
    end
  end
end
