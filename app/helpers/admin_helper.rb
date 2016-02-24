module AdminHelper

  def detail_pannel(name, options ={}, &block)
    pannel_content = capture(&block)
    name.is_a?(Class) ? name.model_name.human : name
    options[:type] ||= 'info'

    dropdown_list_string = <<-HTML
      <div class="panel panel-#{options[:type]}">
        <div class="panel-heading">
          <h3 class="panel-title">#{name}</h3>
        </div>
        <div class="panel-body">
          #{pannel_content}
        </div>

      </div>
    HTML
    dropdown_list_string.html_safe
  end

  def active_for(controller_name, navbar_name)
    controller_name.to_sym == navbar_name.to_s.to_sym ? "active" : ""
  end

  def withdraw_process_txt(record)
    pre_text = record.failure? ? '重新' : ''
    text = if record.wechat_available?
             "微信打款"
           else
             "银行打款"
           end
    pre_text + text
  end

  def withdraw_process_class(record)
    record.wechat_available? ? "btn-success" : "btn-primary"
  end

  def store_banner_sets
    [
      [:store_banner_one, :recommend_resource_one_id],
      [:store_banner_two, :recommend_resource_two_id],
      [:store_banner_thr, :recommend_resource_thr_id]
    ]
  end

  # def store_banner_data(seller)
  #   return @store_banner_data if @store_banner_data.present?

  #   @store_banner_data = []
  #   store_banner_sets.each do |image_method, resource_method|
  #     if seller.__send__("#{image_method}_identifier").present?
  #       product_id = seller.__send__(resource_method)
  #       @store_banner_data << [
  #         seller.__send__("#{image_method}"),
  #         product_id && Product.find_by(id: product_id)
  #       ]
  #     end
  #   end
  #   @store_banner_data
  # end

  def store_banner_data(seller)
    return @store_banner_data if @store_banner_data.present?

    @store_banner_data = []
    advertisements = Advertisement.joins('left join products on (products.id = advertisements.product_id)').
      where('(product_id is not null AND products.status = 1) OR product_id is null').
      where(user_id: seller.id, user_type: 'Ordinary', platform_advertisement: false).
      order('order_number')
    advertisements.each do |advertisement|
      if advertisement.product_id
        url = url_for(controller: :products, action: :show, id: advertisement.product_id)
      elsif advertisement.category_id
        url = store_category_path(store_id: advertisement.user_id, id:advertisement.category_id)
      else
        url = '###'
      end
      @store_banner_data << [
        advertisement.asset_img ,
        url
      ]
    end
    @store_banner_data
  end

  def strftime(time)
    time.strftime("%Y-%m-%d")
  end

  def platform_banner_data
    return @platform_banner_data if @platform_banner_data.present?

    @platform_banner_data = []
    Advertisement.where(platform_advertisement: true, status: 1).order('order_number').each do |platform_advertisement|
        @platform_banner_data << [
          platform_advertisement.asset_img ,
          platform_advertisement.advertisement_url
        ]
    end
    @platform_banner_data
  end
end
