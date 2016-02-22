class HomepageController < ApplicationController
  layout 'mobile'

  before_action :set_user, :set_sharing_link_node

  def show
    @recommend_products = @user.recommends.products.map(&:recommended)
  end

  def recommend_products
    @recommend_products = @user.recommends.products.map(&:recommended)
  end

  def recommend_stores
    @recommend_stores = @user.recommends.stores.map(&:recommended)
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def set_sharing_link_node
    @sharing_link_node ||=
      SharingNode.find_or_create_by_resource_and_parent(current_user, @user)
  end

end
