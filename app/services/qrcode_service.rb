class QrcodeService

  API_KEY = '20150929143547'
  API_URL = 'http://api.wwei.cn/wwei.html'

  attr_reader :text, :logo

  def initialize(text, logo = nil)
    @text = text
    @logo = logo
  end

  def url
    @url ||= request_qrcode_url
  end

  def request_qrcode_url(only_text = false)
    cache_key = only_text ? @text : "#{@text}:#{@logo}"
    cache_key_value = get_cache_key(cache_key)
    cache_url = Rails.cache.read cache_key_value
    return cache_url if cache_url.present?

    payload = {
      data: @text,
      apikey: API_KEY
    }
    payload[:logo] = @logo if !only_text
    response = RestClient.post API_URL, payload
    result = JSON.parse response.body rescue nil

    if result.blank?
      return nil if only_text
      return request_qrcode_url(true) if only_text == false
    end

    if result['status'] == 1
      url = result['data']['qr_filepath']
      Rails.cache.write cache_key_value, url
      url
    else
      nil
    end
  end

  private

  def get_cache_key(identify)
    Digest::MD5.digest identify
  end

end
