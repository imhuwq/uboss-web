class PrivilegeCard < ActiveRecord::Base
  require 'emoji_cleaner'

  include Imagable
  include Orderable

  has_one_image name: :ordinary_store_qrcode_img
  has_one_image name: :service_store_qrcode_img

  belongs_to :user
  belongs_to :seller, class_name: "User"

  validates :user_id, :seller_id, presence: true
  validates_uniqueness_of :user_id, scope: :seller_id
  after_create :create_store_qrcode_img

  delegate :url_helpers, to: 'Rails.application.routes'

  def self.find_or_active_card(user_id, seller_id)
    card = PrivilegeCard.find_or_create_by(user_id: user_id, seller_id: seller_id)
    card.update_column(:actived, true) if not card.actived?
    card
  end

  def discount(product_inventory)
    (product_inventory.price - privilege_amount(product_inventory)) * 10 / product_inventory.price
  end

  def returning_amount(product_inventory)
    result = product_inventory.share_amount_lv_1 - amount(product_inventory)
    result > 0 ? result : 0
  end

  def privilege_amount(product_inventory)
    result = amount(product_inventory) + product_inventory.privilege_amount
    result > product_inventory.max_privilege_amount ? product_inventory.max_privilege_amount : result
  end

  def amount(product_inventory)
    (user.privilege_rate * product_inventory.share_amount_lv_1 / 100).truncate(2)
  end

  def ordinary_store_qrcode_img
    super || build_ordinary_store_qrcode_img
  end

  def service_store_qrcode_img
    super || build_service_store_qrcode_img
  end

  def ordinary_store_qrcode_img_url(expire = false)
    if ordinary_store_qrcode_img.new_record? || daily_expired_or_info_charged?(expire)
      delay.get_and_save_store_qrcode_url
      return "http://imager.ulaiber.com/req/1?#{ordinary_store_qrcode_params.merge(mode: 0).to_param}"
    end

    reload.ordinary_store_qrcode_img.image_url
  end

  def service_store_qrcode_img_url(expire = false)
    if service_store_qrcode_img.new_record? || daily_expired_or_info_charged?(expire)
      delay.get_and_save_store_qrcode_url
      return "http://imager.ulaiber.com/req/1?#{service_store_qrcode_params.merge(mode: 0).to_param}"
    end

    reload.service_store_qrcode_img.image_url
  end

  private

  def create_store_qrcode_img
    delay.get_and_save_store_qrcode_url
  end

  def get_and_save_store_qrcode_url
    if img_url = get_store_qrcode_img_url(ordinary_store_qrcode_params)
      ordinary_store_qrcode_img.remote_avatar_url = img_url
      ordinary_store_qrcode_img.save
    end

    if img_url = get_store_qrcode_img_url(service_store_qrcode_params)
      service_store_qrcode_img.remote_avatar_url = img_url
      service_store_qrcode_img.save
    end

    self.user_name = user.nickname
    self.user_img  = user.read_attribute(:avatar)
    self.service_store_cover = service_store.read_attribute(:store_cover)
    self.ordinary_store_cover = ordinary_store.read_attribute(:store_cover)
    self.qrcode_expire_at = Time.current + Rails.application.secrets.privilege_card['qrcode_expire_days'].day
    self.save
  end

  def get_store_qrcode_img_url(qrcode_params)
    request_uri = URI("http://imager.ulaiber.com/req/1?#{qrcode_params.to_param}")
    res = Net::HTTP.get_response request_uri

    if res.is_a?(Net::HTTPSuccess)
      res = JSON.parse res.body
      res["url"]
    end
  end

  def ordinary_store_qrcode_params
    {
      user_img_url: user.image_url(:w60),
      item_img_url: ordinary_store.store_cover_url(:w250x250),
      qrcode_content: url_helpers.sharing_url(code: sharing_node.code, host: default_host),
      username: EmojiCleaner.clear(user.nickname),
      mode: 1
    }
  end

  def service_store_qrcode_params
    {
      user_img_url: user.image_url(:w60),
      item_img_url: service_store.store_cover_url(:w250x250),
      qrcode_content: url_helpers.sharing_url(code: sharing_node.code, host: default_host, redirect: url_helpers.service_store_path(service_store)),
      username: EmojiCleaner.clear(user.nickname),
      mode: 1
    }
  end

  def daily_expired_or_info_charged?(expire)
    (
      expire && qrcode_expire_at < (Rails.env.production? ? Time.current : Time.current + Rails.application.secrets.privilege_card['qrcode_expire_days'].day - 5.minute)
    ) || (
      user_name != user.nickname ||
      user_img != user.read_attribute(:avatar) ||
      service_store_cover  != service_store.read_attribute(:store_cover) ||
      ordinary_store_cover != ordinary_store.read_attribute(:store_cover)
    )
  end

  def service_store
    seller.service_store
  end

  def ordinary_store
    seller.ordinary_store
  end

  def sharing_node
    SharingNode.find_or_create_by(user_id: user_id, seller_id: seller_id)
  end

  def default_host
    Rails.env.production? ? "http://uboss.me" : "http://stage.uboss.me"
  end

end
