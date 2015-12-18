module SharingResource
  extend ActiveSupport::Concern

  private

  def get_sharing_node
    if @store_scode = get_seller_sharing_code(@seller.id)
      @sharing_node = SharingNode.find_by(code: @store_scode)
    end
  end

  def set_sharing_link_node
    if current_user.present?
      @sharing_link_node ||=
        SharingNode.find_or_create_by_resource_and_parent(current_user, @seller)
    end
  end

end
