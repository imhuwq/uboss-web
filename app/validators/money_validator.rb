class MoneyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    before_type_cast = :"#{attribute}_before_type_cast"

    raw_value = record.send(before_type_cast) if record.respond_to?(before_type_cast)
    raw_value ||= value

    unless value = parse_raw_value_as_a_number(raw_value)
      record.errors.add(attribute, :not_a_number)
      return
    end

    if value < 0
      record.errors.add(attribute, options[:message] || '必须大于零')
    end
  end

  private

  def parse_raw_value_as_a_number(raw_value)
    Kernel.Float(raw_value) if raw_value !~ /\A0[xX]/
  rescue ArgumentError, TypeError
    nil
  end
end
