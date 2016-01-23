class RefundMessagesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_order_item
  before_action :find_order_item_refund, only: [:new, :create]

  def new
    @refund_message = RefundMessage.new
    @refund_messages = @order_item.refund_messages.order('created_at DESC')
  end

  def create
    @refund_message = RefundMessage.new(refund_message_params)
    @refund_message.user = current_user
    add_multi_img
    if validate_message && @refund_message.save
      redirect_to new_order_item_order_item_refund_refund_message_path(order_item_id: @order_item.id, order_item_refund_id: @refund.id)
    else
      @refund_messages = current_user.refund_messages.order('created_at desc')
      render 'new'
    end
  end

  private

  def validate_message
    if @refund_message.message.blank?
      @refund_message.errors.add(:message, '不能为空')
      false
    else
      true
    end
  end

  def refund_message_params
    params.require(:refund_message).permit(:message, :user_type).merge(order_item_refund_id: @refund.id)
  end

  def add_multi_img
    avatars = params.require(:refund_message).permit(:avatar)
    avatars[:avatar].split(',').each do |avatar|
      @refund_message.asset_imgs << AssetImg.create(resource: @refund_message, avatar: avatar)
    end
  end

  def find_order_item_refund
    @refund = current_user.order_item_refunds.find(params[:order_item_refund_id])
  end

  def find_order_item
    @order_item = current_user.order_items.find(params[:order_item_id])
  end

end
