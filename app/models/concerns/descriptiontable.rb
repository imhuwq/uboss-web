module Descriptiontable
  extend ActiveSupport::Concern

  WHITE_LIST_CONPONER = {
    elements: %w(br p h1 h2 h3 h4 h5 blockquote strong em del u ul li ol img),
    attributes: {
      'all' => %w[style],
      'img' => %w(src alt),
    },
    add_attributes: { a: { rel: "nofollow" } },
    css: {
      properties: %w[margin-left text-align]
    },
    protocols: {
      img: { src:  %w(http https) }
    }
  }.freeze

  included do
    has_one :description, dependent: :destroy, as: :resource, autosave: true
  end

  def content
    description.content
  end

  def content_images=(images)
    text = images.map { |image|
      "<p><img src='#{image}-w640'></p>"
    }.join('')
    self.content = text
  end

  def content=(text)
    description.content = Sanitize.fragment(text, WHITE_LIST_CONPONER)
    text
  end

  def description
    super || build_description
  end
end
