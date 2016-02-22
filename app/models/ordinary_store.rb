class OrdinaryStore < UserInfo

  validates_uniqueness_of :user_id, message: :only_ordinary_store
  validates_numericality_of :platform_service_rate, :agent_service_rate,
    less_than_or_equal_to: 50, allow_blank: true

  before_update :record_rate_history, if: -> {
    changes.include?(:platform_service_rate) || changes.include?(:agent_service_rate)
  }
  has_many :ordinary_products

  def store_cover_name
    store_cover.try(:file).try(:filename)
  end

  def store_banner(name)
    case name
    when :store_banner_one
      store_banner_one.try(:file).try(:filename)
    when :store_banner_two
      store_banner_two.try(:file).try(:filename)
    when :store_banner_thr
      store_banner_thr.try(:file).try(:filename)
    end
  end

  private

  def record_rate_history
    self.service_rate_histroy ||= {}

    from_service_rate = "#{platform_service_rate_was}|#{agent_service_rate_was}"
    to_service_rate = "#{platform_service_rate}|#{agent_service_rate}"

    self.service_rate_histroy[Time.now.to_datetime] = {
      from_service_rate: from_service_rate,
      to_service_rate: to_service_rate
    }
  end
end
