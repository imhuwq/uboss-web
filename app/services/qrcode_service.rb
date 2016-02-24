class QrcodeService

  API_KEY = '20150929143547'
  API_URL = 'http://api.wwei.cn/wwei.html'

  attr_reader :text, :logo, :uploader

  def initialize(text, logo = nil)
    @text = text
    @logo = logo
    @uploader = QrImageUploader.new
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
      content: @text,
      mode: 0
    }
    payload[:logo] = @logo if !only_text

    begin
      uploader.download!("http://imager.ulaiber.com/req/qrcode?#{payload.to_query}")
      uploader.store!
      Rails.cache.write cache_key_value, uploader.url, expires_in: 7.days
      uploader.url
    rescue Exception => e
      send_exception_message(e, payload)
      nil
    end
  end

  private

  def get_cache_key(identify)
    Digest::SHA1.hexdigest identify
  end

end
