class ImageUploader < CarrierWave::Uploader::Base

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}"
  end

  def url(version_name = "")
    @url ||= super({})
    version_name = version_name.to_s
    return @url if version_name.blank?
    # if not version_name.in?(IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES)
    #   # To protected version name using, when it not defined, this will be give an error message in development environment
    #   raise "ImageUploader version_name:#{version_name} not allow."
    # end
    [@url, version_name].join("-") # thumb split with "-" 
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    return nil unless original_filename
    @name ||= Digest::MD5.hexdigest(cache_id)
    if file.respond_to? :extension
      "#{@name}.#{file.extension}"
    elsif file.respond_to?(:path) # Upyun file
      "#{@name}#{File.extname(file.path)}"
    end
  end

end
