class UpyunUploader < CarrierWave::Uploader::Base

  storage :upyun

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}"
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
