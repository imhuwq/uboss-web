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
    has_one :description, -> { where(content_type: nil) }, dependent: :destroy, as: :resource, autosave: true
  end

  module ClassMethods
    def has_one_content(options = {})
      options = {
        class_name: 'Description',
        as:         :resource,
        dependent:  :destroy,
        autosave:   true
      }.merge(options)

      name = options.delete(:name)
      content_type = options.delete(:type) || 'description'
      has_one :"#{name}_description", -> { where(content_type: content_type) }, options
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{name}_description
          super || build_#{name}_description
        end

        def #{name}
          #{name}_description.content
        end

        def #{name}=(text)
          #{name}_description.content = Sanitize.fragment(text, WHITE_LIST_CONPONER)
          #{name}_description.content
        end
      RUBY
    end
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
