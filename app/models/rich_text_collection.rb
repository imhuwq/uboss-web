class RichTextCollection < ActiveRecord::Base

  belongs_to :resource

  def content=(text)
    sanitized_content = Sanitize.fragment(
      text,
      Sanitize::Config.merge(
        Sanitize::Config::RELAXED,
        elements: Sanitize::Config::RELAXED[:elements] - ['a']
      )
    )

    write_attribute(:content, sanitized_content)
  end
end
