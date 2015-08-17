module Descriptiontable
  extend ActiveSupport::Concern

  included do
    has_one :description, dependent: :destroy, as: :resource, autosave: true
  end

  def content
    description.content
  end

  def content=(text)
    description.content = text
    text
  end

  def description
    super || build_description
  end
end
