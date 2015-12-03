class OrdinaryStore < UserInfo
  validates_uniqueness_of :user_id, message: :only_ordinary_store

  def store_cover_name
    store_cover.try(:file).try(:filename)
  end
end
