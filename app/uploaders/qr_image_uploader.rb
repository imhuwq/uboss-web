class QrImageUploader < CarrierWave::Uploader::Base

  def store_dir
    "qr_images/file"
  end

  def url(version_name = "")
    @url ||= super({})
    version_name = version_name.to_s
    return @url if version_name.blank?
    [@url, version_name].join("-")
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
