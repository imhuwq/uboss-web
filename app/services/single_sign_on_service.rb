class SingleSignOnService

  ACCESSORS = [:nonce, :name, :username, :email, :avatar_url, :avatar_force_update, :require_activation,
               :about_me, :external_id, :return_sso_url, :admin, :moderator, :suppress_welcome_message]
  FIXNUMS = []
  BOOLS = [:avatar_force_update, :admin, :moderator, :require_activation, :suppress_welcome_message]
  NONCE_EXPIRY_TIME = 10.minutes

  attr_accessor(*ACCESSORS)
  attr_accessor :sso_secret, :sso_url

  def self.sso_secret
    ENV['DISCOURSE_SECRET']
  end

  def self.sso_url
    ENV['DISCOURSE_CALLBACK_URL']
  end

  def self.parse(payload, sso_secret = nil)
    sso = new
    sso.sso_secret = sso_secret if sso_secret

    parsed = Rack::Utils.parse_query(payload)
    if sso.sign(parsed["sso"]) != parsed["sig"]
      diags = "\n\nsso: #{parsed["sso"]}\n\nsig: #{parsed["sig"]}\n\nexpected sig: #{sso.sign(parsed["sso"])}"
      if parsed["sso"] =~ /[^a-zA-Z0-9=\r\n\/+]/m
        raise RuntimeError, "The SSO field should be Base64 encoded, using only A-Z, a-z, 0-9, +, /, and = characters. Your input contains characters we don't understand as Base64, see http://en.wikipedia.org/wiki/Base64 #{diags}"
      else
        raise RuntimeError, "Bad signature for payload #{diags}"
      end
    end

    decoded = Base64.decode64(parsed["sso"])
    decoded_hash = Rack::Utils.parse_query(decoded)

    ACCESSORS.each do |k|
      val = decoded_hash[k.to_s]
      val = val.to_i if FIXNUMS.include? k
      if BOOLS.include? k
        val = ["true", "false"].include?(val) ? val == "true" : nil
      end
      sso.send("#{k}=", val)
    end

    decoded_hash.each do |k,v|
      # 1234567
      # custom.
      #
      if k[0..6] == "custom."
        field = k[7..-1]
        sso.custom_fields[field] = v
      end
    end

    sso
  end

  def assign_attributes_with_user(user)
    @email = user.email || "#{user.login}@uboss.me" # FAKE Email for discourse if blank
    @name = user.identify
    @username = user.login
    @external_id = user.id
    @avatar_url = user.avatar_url
    @avatar_force_update = true
    @admin = user.is_super_admin?
  end

  def sso_secret
    @sso_secret || self.class.sso_secret
  end

  def sso_url
    @sso_url || self.class.sso_url
  end

  def custom_fields
    @custom_fields ||= {}
  end


  def sign(payload)
    OpenSSL::HMAC.hexdigest("sha256", sso_secret, payload)
  end


  def to_url(base_url=nil)
    base = "#{base_url || sso_url}"
    "#{base}#{base.include?('?') ? '&' : '?'}#{payload}"
  end

  def payload
    payload = Base64.encode64(unsigned_payload)
    "sso=#{CGI::escape(payload)}&sig=#{sign(payload)}"
  end

  def unsigned_payload
    payload = {}
    ACCESSORS.each do |k|
     next if (val = send k) == nil

     payload[k] = val
    end

    if @custom_fields
      @custom_fields.each do |k,v|
        payload["custom.#{k}"] = v.to_s
      end
    end

    Rack::Utils.build_query(payload)
  end

end
