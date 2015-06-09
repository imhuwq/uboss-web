class MobileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A(\s*)(?:\(?[0\+]?\d{1,3}\)?)[\s-]?(?:0|\d{1,4})[\s-]?(?:(?:13\d{9})|(?:\d{7,8}))(\s*)\Z|\A[569][0-9]{7}\Z/
      record.errors[attribute] << (options[:message] || "is not an mobile")
    end
  end
end
