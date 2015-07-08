module ProductsHelper

  def product_sharing_link(product, sharing_node=nil)
    if sharing_node.blank?
      product_url(product)
    else
      sharing_url(sharing_node)
    end
  end

end
