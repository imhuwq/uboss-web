class OrdinaryStore < UserInfo
  validates_uniqueness_of :user_id, message: :only_ordinary_store

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
end
