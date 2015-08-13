class RichTextCollection < ActiveRecord::Base
  belongs_to :resource

  before_save :sanitize_content

  def sanitize_content
    self.content = Sanitize.fragment(self.content, Sanitize::Config.merge(Sanitize::Config::RELAXED,
                        :elements        => Sanitize::Config::RELAXED[:elements] - ['a']
                        ))
  end
end
