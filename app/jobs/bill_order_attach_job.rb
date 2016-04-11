class BillOrderAttachJob < ActiveJob::Base
  queue_as :default

  attr_accessor :user

  def perform(opts)
    @user = opts[:user]

    return false if user.weixin_openid.blank?

    BillOrder.where(user_id: nil, weixin_openid: user.weixin_openid).
      update_all(user_id: user.id)
  end
end
