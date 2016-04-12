module Admin::CategoriesHelper
  def except_other_has_many_categories(categories)
    if categories.where(name: '其他').present? && categories.count == 2
      false
    else
      true
    end
  end
end
