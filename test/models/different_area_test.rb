require 'test_helper'

class DifferentAreaTest < ActiveSupport::TestCase
  test '至少添加一个省份' do
    different_area = build(:different_area)
    assert_not different_area.save
  end

  test '包含一个省份' do
    assert create(:different_area, regions: [create(:region)])
  end
end
