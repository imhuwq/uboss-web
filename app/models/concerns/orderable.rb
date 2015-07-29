require 'active_support/concern'

module Orderable
  extend ActiveSupport::Concern

  included do
    scope :today, -> { where("#{table_name}.created_at >= ?", Time.now.beginning_of_day) }
  end

  module ClassMethods
    def recent order_column = nil, order_type = nil
      order_column ||= "id"
      order_type   ||= "DESC"
      order_column = "#{ table_name }.#{ order_column }" unless order_column.to_s.include?(".")
      all.order("#{ order_column } #{ order_type }")
    end

    def paginate_by_timestamp before_ts, after_ts, column_name = nil
      column_name ||= "created_at"
      column_name = "#{ table_name }.#{ column_name }" unless column_name.to_s.include?(".")
      all.tap do |_scope|
        _scope.where! ["#{column_name} < ?", before_ts] if before_ts
        _scope.where! ["#{column_name} > ?", after_ts] if after_ts
      end
    end
  end
end
