class QrcodeService

  API_KEY = '20150929143547'
  API_URL = 'http://api.wwei.cn/wwei.html'

  def self.request_qrcode_url(txt, logo = nil)
    cache_key_value = cache_key("#{txt}:#{logo}")
    cache_url = Rails.cache.read cache_key_value
    return cache_url if cache_url.present?

    response = RestClient.post API_URL, data: txt, apikey: API_KEY, logo: logo
    result = JSON.parse response.body rescue nil
    return nil if result.blank?

    if result['status'] == 1
      url = result['data']['qr_filepath']
      Rails.cache.write cache_key_value, url
      url
    else
      nil
    end
  end

  private
  def self.cache_key(identify)
    Digest::MD5.digest identify
  end

end
