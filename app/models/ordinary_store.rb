class OrdinaryStore < UserInfo
  validates_uniqueness_of :user_id, message: :only_ordinary_store
end
