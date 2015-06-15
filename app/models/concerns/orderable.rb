require 'active_support/concern'

module Orderable
  extend ActiveSupport::Concern

  included do
    scope :today, -> { where("#{self.table_name}.created_at >= ?", Time.now.beginning_of_day) }
  end

  module ClassMethods
    def recent order_column = "created_at"
      all.order("#{self.table_name }.#{ order_column || "created_at" } DESC")
    end
  end

end
