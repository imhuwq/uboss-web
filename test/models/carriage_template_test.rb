require 'test_helper'

class CarriageTemplateTest < ActiveSupport::TestCase
  test 'must has one different_areas' do
    tpl = build(:carriage_template)
    assert_not tpl.save
  end

  test '已用模板不能删除' do
    different_area = create(:different_area, regions: [create(:region)])
    tpl = create(:carriage_template, different_areas: [different_area])
    product = create(:product, carriage_template: tpl)
    assert_not tpl.destroy
  end

  test '非引用模板可以删除' do
    different_area = create(:different_area, regions: [create(:region)])
    tpl = create(:carriage_template, different_areas: [different_area])
    assert tpl.destroy
  end

  test 'name 唯一且不能为空' do
    different_area = create(:different_area, regions: [create(:region)])
    tpl1 = create(:carriage_template, different_areas: [different_area])
    tpl2 = build(:carriage_template, different_areas: [different_area])
    assert_not tpl2.save
  end

  test 'has many different_areas' do
    different_area = create(:different_area, regions: [create(:region)])
    tpl1 = create(:carriage_template, different_areas: [different_area])
    assert tpl1.different_areas
  end

  test 'has many products' do
    different_area = create(:different_area, regions: [create(:region)])
    tpl1 = create(:carriage_template, different_areas: [different_area])
    assert tpl1.products
  end
end
