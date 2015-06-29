require 'active_support/concern'

module Numberable
  extend ActiveSupport::Concern

  included do
    before_create :set_number
  end

  private

  def generate_number
    "#{(Time.now - Time.parse('2012-12-12')).to_i}#{rand(100000).to_s.rjust(5,'0')}#{SecureRandom.hex(3).upcase}"
  end

  def set_number
    loop do
      tmp_number = generate_number
      unless self.class.find_by(number: tmp_number)
        self.number = tmp_number and break
      end
    end
  end
end
