class IdentityCardCodeValidator < ActiveModel::EachValidator
  CODE15 = /^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/ # 15位身份证号
  CODE18 = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/ # 18位身份证号

  def validate_each(record, attribute, value)
    if value =~ CODE15 || value =~ CODE18
      return true
    else
      record.errors[attribute] << (options[:message] || '身份证格式错误.')
    end
  end
end
