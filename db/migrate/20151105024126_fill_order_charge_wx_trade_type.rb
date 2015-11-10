class FillOrderChargeWxTradeType < ActiveRecord::Migration
  def up
    say_with_time 'FillOrderChargeWxTradeType' do
      OrderCharge.where(wx_code_url: nil).update_all(wx_trade_type: 'JSAPI')
      OrderCharge.where('wx_code_url IS NOT NULL').update_all(wx_trade_type: 'NATIVE')
    end
  end
end
