module WxPayHelper

  def stub_wx_invoke_unifiedorder!(options = {})
    stub_wx_api options.merge(api_name: :invoke_unifiedorder)
  end

  def stub_wx_invoke_closeorder!(options = {})
    stub_wx_api options.merge(api_name: :invoke_closeorder)
  end

  def stub_wx_invoke_orderquery!(options = {})
    stub_wx_api options.merge(api_name: :order_query)
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

  private
  def stub_wx_api(options = {})
    api_name = options.delete(:api_name)
    data = options[:data] || {}
    WxPay::Service.expects(api_name).returns(
      WxPay::Result[{'xml' => {
        "result_code"=>"SUCCESS",
        "return_code"=>"SUCCESS",
        "trade_state"=>"SUCCESS",
        "time_end"=>"20151105134307",
        "total_fee"=>"1",
        "trade_type"=>"JSAPI",
      }.merge(data)}]
    )
  end

end

ActiveSupport::TestCase.send(:include, WxPayHelper)
