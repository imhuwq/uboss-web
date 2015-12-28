require 'test_helper'

class MoneyValidationTest < ActiveSupport::TestCase

  before(:each) do
    @validator = MoneyValidator.new(attributes: {amount: 0})
    @mock = mock('model')
  end

  test "should validate valid number" do
    @mock.stubs("errors").returns([])
    @validator.validate_each(@mock, "amount", 123.12)
    assert_equal 0, @mock.errors.size
  end

  test "should validate invalid number" do
    @mock.stubs("errors").returns([])
    @mock.errors.stubs('add')
    @validator.validate_each(@mock, "amount", "ab")
  end

  test "should validate valid number greater 0" do
    @mock.stubs("errors").returns([])
    @validator.validate_each(@mock, "amount", 123.12)
    assert_equal 0, @mock.errors.size
  end

  test "should validate invalid number greater 0" do
    @mock.stubs("errors").returns([])
    @mock.errors.stubs('add')
    @validator.validate_each(@mock, "amount", -123)
  end

end
