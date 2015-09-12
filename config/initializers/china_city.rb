module ChinaCity extend self

  class << self
    alias_method :old_list, :list
  end

  def self.list(parent_id = nil, opts = {})
    opts[:province] ||= false
    if parent_id.blank?
      provide_provinces_or_none_by_condition(opts[:province])
    else
      old_list(parent_id) rescue provide_provinces_or_none_by_condition(opts[:province])
    end
  end

  private

  def self.provide_provinces_or_none_by_condition(province = false)
    province ? old_list : []
  end

end
