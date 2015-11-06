module WxPayHelper

  def stub_wx_invoke_unifiedorder!
    WxPay::Service.expects(:invoke_unifiedorder).returns(
      WxPay::Result[{'xml' => {
        "result_code"=>"SUCCESS",
        "return_code"=>"SUCCESS",
        "time_end"=>"20151105134307",
        "total_fee"=>"1",
        "trade_type"=>"JSAPI",
      }}]
    )
  end

  def stub_wx_invoke_closeorder!
    WxPay::Service.expects(:invoke_closeorder).returns(
      WxPay::Result[{'xml' => {
        "result_code"=>"SUCCESS",
        "return_code"=>"SUCCESS",
      }}]
    )
  end

  def stub_wx_invoke_orderquery!
    WxPay::Service.expects(:order_query).returns(
      WxPay::Result[{'xml' => {
        "result_code"=>"SUCCESS",
        "return_code"=>"SUCCESS",
        "time_end"=>"20151105134307",
        "total_fee"=>"1",
        "trade_type"=>"JSAPI",
      }}]
    )
  end

  def mock_wx_result(options = {})
    options = {
      success: true,
      result: {
        "result_code"=>"SUCCESS",
        "return_code"=>"SUCCESS",
        "time_end"=>"20151105134307",
        "total_fee"=>"1",
        "trade_type"=>"JSAPI",
      }
    }.merge(options)
    result = WxPay::Result[{'xml' => options[:result]}]
    result.stubs(:success?).returns(options[:success])
    result
  end

end

ActiveSupport::TestCase.send(:include, WxPayHelper)
