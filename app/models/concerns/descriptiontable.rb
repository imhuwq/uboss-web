module Descriptiontable
  extend ActiveSupport::Concern

  included do
    has_one :description, dependent: :destroy, as: :resource, autosave: true
  end

  def content
    description.content
  end

  def content=(text)
    description.content = Sanitize.fragment(text,
      Sanitize::Config.merge(
        Sanitize::Config::BASIC,
        elements: Sanitize::Config::BASIC[:elements] - ['a']
      )
    )
    text
  end

  def description
    super || build_description
  end
end
