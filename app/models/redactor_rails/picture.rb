class RedactorRails::Picture < RedactorRails::Asset
  mount_uploader :data, RedactorRailsPictureUploader, mount_on: :data_file_name

  def url(version='')
    data.url(:w640)
  end

end
