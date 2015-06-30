class RedactorRailsDocumentUploader < UpyunUploader

  include RedactorRails::Backend::CarrierWave

  storage :upyun

  self.upyun_bucket = Rails.application.secrets.upyun_file_bucket
  self.upyun_bucket_host = Rails.application.secrets.upyun_file_bucket_host

  def extension_white_list
    RedactorRails.document_file_types
  end
end
