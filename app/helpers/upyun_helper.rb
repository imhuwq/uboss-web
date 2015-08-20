require "base64"
require 'digest/md5'

# http://docs.upyun.com/api/form_api/
module UpyunHelper

  def upyun_bucket
    Rails.application.secrets.upyun['bucket']
  end

  def upyun_bucket_key
    Rails.application.secrets.upyun['bucket_key']
  end

  def upyun_bucket_host
    Rails.application.secrets.upyun['bucket_host']
  end

  def upyun_form_url
    "#{Rails.application.secrets.upyun['form_api_url']}/#{upyun_bucket}"
  end

  def upyun_policy_json options={}
    options[:prefix] ||= ""
    {
      "bucket" => upyun_bucket,
      "save-key" => "#{options[:prefix]}/{filemd5}{.suffix}",
      "return-url" => "#{request.base_url}/__upyun_uploaded",
      "expiration" => 30.minutes.since.to_i
    }
  end

  def upyun_policy options={}
    Base64.encode64(upyun_policy_json(options).to_json).gsub("\n", "")
  end

  def upyun_signature options={}
    Digest::MD5.hexdigest [upyun_policy(options), upyun_bucket_key].join("&")
  end

  def upyun_meta_tags options={}
    [
      tag(:meta, name: "upyun-form-url", content: upyun_form_url),
      tag(:meta, name: "upyun-policy", content: upyun_policy(options)),
      tag(:meta, name: "upyun-signature", content: upyun_signature(options)),
      tag(:meta, name: "upyun-domain", content: upyun_bucket_host)
    ].join("\n").html_safe
  end
end
