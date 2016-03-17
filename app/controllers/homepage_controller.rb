class HomepageController < ApplicationController
  layout 'mobile'

  before_action :set_user

  def show
    @recommend_products = @user.recommended_products
  end

  def recommend_products
    @recommend_products = @user.recommended_products
  end

  def recommend_stores
    @recommend_stores = @user.recommends.stores.map(&:recommended)
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
