require 'test_helper'

class OrderFormTest < ActiveSupport::TestCase
  #:product_id, :amount, :mobile, :captcha, :user_address_id, :deliver_username,
  #:province, :city, :country, :street, :deliver_mobile, :sharing_code

  before do
    @product = create(:product, count: 100)
    @seller = @product.user
    @buyer = create(:user_with_address)
  end

  describe 'when new user' do
    it 'should create buyer and user_address' do
      MobileCaptcha.expects(:auth_code).with('13800002222', '123').returns(true)
      order_form = OrderForm.new(
        product_id: @product.id,
        amount: 1,
        mobile: '13800002222',
        captcha: '123',
        deliver_username: 'newBuyer',
        province: 'GD',
        city: 'SZ',
        country: 'NS',
        street: 'kejiyuan',
        session: {},
        deliver_mobile: '13800002222'
      )
      assert_equal true, order_form.save

      user = User.find_by(login: '13800002222')

      assert_not_nil user
      assert_equal 1, user.user_addresses.count
    end
  end

  it 'should decrease product stock and inc seller orders' do
    assert_equal true, OrderForm.new(
      product_id: @product.id,
      amount: 12,
      session: {},
      buyer: @buyer,
      user_address_id: @buyer.default_address.id
    ).save

    assert_equal 1, @seller.sold_orders.count
    assert_equal 88, @product.reload.count
  end

  describe 'when old user without login' do
    it 'should auto find and attach' do
      MobileCaptcha.expects(:auth_code).returns(true)
      assert_equal true, OrderForm.new(
        product_id: @product.id,
        amount: 12,
        mobile: @buyer.mobile,
        captcha: '123',
        deliver_username: 'newBuyer',
        province: 'GD',
        city: 'SZ',
        country: 'NS',
        street: 'kejiyuan',
        session: {},
        deliver_mobile: '13800002222'
      ).save

      assert_equal 1, @buyer.orders.count
    end
  end

  it 'should verify mobile while no buyer' do
    MobileCaptcha.expects(:auth_code).with('13800002222', 'MustBeWrong').returns(false)
    order_form = OrderForm.new(product_id: @product.id, mobile: '13800002222', captcha: 'MustBeWrong')

    assert_equal false, order_form.valid?
    assert_includes order_form.errors.keys, :captcha
  end

end
