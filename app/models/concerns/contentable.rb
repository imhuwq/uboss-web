module Contentable
  extend ActiveSupport::Concern

  included do
    has_one :rich_text_collection, as: :rich_text, autosave: true
  end

  def content
    rich_text_collection.content
  end

  def content=(text)
    rich_text_collection.content = text
    text
  end

  def rich_text_collection
    super || build_rich_text_collection
  end
end
