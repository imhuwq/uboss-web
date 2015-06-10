require 'active_support/concern'

module Orderable
  extend ActiveSupport::Concern

  module ClassMethods
    def today
      where("#{self.table_name}.created_at >= ?", Time.now.beginning_of_day)   
    end

    def recent order_column = "created_at"
      all.order("#{self.table_name }.#{ order_column || "created_at" } DESC")
    end
  end

end
