class PrivilegeCard < ActiveRecord::Base

  include Imagable
  include Orderable

  has_one_image name: :ordinary_store_qrcode_img
  has_one_image name: :service_store_qrcode_img

  belongs_to :user
  belongs_to :seller, class_name: "User"

  validates :user_id, :seller_id, presence: true
  validates_uniqueness_of :user_id, scope: :seller_id

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

  #private

  def generate_store_qrcode_img
    request_image_query_param = {
      user_img_url: user.image_url(:thumb),
      item_img_url: seller.ordinary_store.store_cover_url(:thumb),
      #item_img_url: seller.service_store.store_cover_url(:thumb),
      qrcode_content: 'http://stage.uboss.cn',
      username: user.nickname,
      mode: 1
    }.to_param

    request_uri = URI("http://imager.ulaiber.com/req/1?#{request_image_query_param}")
    res = Net::HTTP.get_response request_uri

    if res.is_a?(Net::HTTPSuccess)
      res = JSON.parse res.body
      if res["url"].present?
        ordinary_store_qrcode_img.remote_avatar_url = res["url"]
        ordinary_store_qrcode_img.save
        #service_store_qrcode_img.remote_avatar_url = res["url"]
        #service_store_qrcode_img.save
      end
    end
  end

end
