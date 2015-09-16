class Region < ActiveRecord::Base
  has_and_belongs_to_many :different_areas

  scope :provinces, -> { where(parent_id: nil)}

  def parent
    Region.find(parent_id) rescue nil
  end
end
