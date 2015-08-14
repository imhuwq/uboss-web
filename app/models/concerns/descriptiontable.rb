module Descriptiontable
  extend ActiveSupport::Concern

  included do
    has_one :content, dependent: :destroy, as: :resource, autosave: true
  end

  def description
    content.content
  end

  def description=(text)
    content.content = text
    text
  end

  def content
    super || build_content
  end
end
