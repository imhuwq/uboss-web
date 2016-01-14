# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  #navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  #navigation.selected_class = 'selected'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  navigation.active_leaf_class = 'actived-leaf'

  # Specify if item keys are added to navigation items as id. Defaults to true
  #navigation.autogenerate_item_ids = true

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  navigation.id_generator = Proc.new {|key| "admin-nav-#{key}"}

  # If you need to add custom html around item names, you can define a proc that
  # will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  #navigation.name_generator = Proc.new {|name, item| "<span>#{name}</span>"}

  # Specify if the auto highlight feature is turned on (globally, for the whole navigation). Defaults to true
  #navigation.auto_highlight = true

  # Specifies whether auto highlight should ignore query params and/or anchors when
  # comparing the navigation items with the current URL. Defaults to true
  #navigation.ignore_query_params_on_auto_highlight = true
  #navigation.ignore_anchors_on_auto_highlight = true

  # If this option is set to true, all item names will be considered as safe (passed through html_safe). Defaults to false.
  #navigation.consider_item_names_as_safe = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>if: -> { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>unless: -> { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #
    primary.item :main,   '主页', admin_root_path,             {}
    primary.item :income, '收益', admin_withdraw_records_path do |sub_nav|
      sub_nav.item :withdraws, '提现', admin_withdraw_records_path, highlights_on: :subpath
      sub_nav.item :bank_cards, '银行卡', admin_bank_cards_path, highlights_on: :subpath
    end
    primary.item :agent,  'U客',  admin_sellers_path,          {}
    primary.item :city_manager, '城市运营商', admin_city_managers_path do |sub_nav|
      sub_nav.item :city_managers,          '城市运营商', admin_city_managers_path
      sub_nav.item :cities_city_managers,   '权限管理',   cities_admin_city_managers_path
      sub_nav.item :revenues_city_managers, '商家营收',   revenues_admin_city_managers_path
      sub_nav.item :added_city_managers,    '新增商家',   added_admin_city_managers_path
    end

    # Add an item which has a sub navigation (same params, but with block)
    primary.item :seller, '电商店铺', admin_products_path, {} do |sub_nav|
      # Add an item to the sub navigation (same params again)
      sub_nav.item :store,  '店铺', admin_store_path(current_user) do |thr_nav|
        thr_nav.item :edit_store, '店铺设置', admin_store_path(current_user)
      end
      sub_nav.item :products, '商品', admin_products_path, {} do |thr_nav|
        thr_nav.item :new_products, '商品', admin_products_path, highlights_on: :subpath
        thr_nav.item :new_products, '运费模板', admin_carriage_templates_path, highlights_on: :subpath
        thr_nav.item :new_products, '商品分组', admin_categories_path, highlights_on: :subpath
      end
      sub_nav.item :orders,  '订单', admin_orders_path, highlights_on: :subpath
    end

    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    primary.item :uboss, 'UBOSS', admin_agents_path, class: 'special', if: -> { current_user.is_super_admin? } do |sub_nav|
      sub_nav.item :uboss_ops, '运营', admin_agents_path do |thr_nav|
        thr_nav.item :agents,         '创客',     admin_agents_path, highlights_on: :subpath
        thr_nav.item :certifications, '认证',     persons_admin_certifications_path, highlights_on: %r(certifications|authentication)
        thr_nav.item :platform_ads,   '平台广告', admin_platform_advertisements_path, highlights_on: :subpath
      end
      sub_nav.item :financial, '交易明细', admin_transactions_path do |thr_nav|
        thr_nav.item :sharing_incomes, '分享分成', admin_sharing_incomes_path, highlights_on: :subpath
        thr_nav.item :transactions, '交易明细', admin_transactions_path, highlights_on: :subpath
      end
      sub_nav.item :users, '账户管理', admin_users_path
      sub_nav.item :backend_status, '后台队列', admin_backend_status_path
    end

    # you can also specify html attributes to attach to this particular level
    # works for all levels of the menu
    #primary.dom_attributes = {id: 'menu-id', class: 'menu-class'}

    # You can turn off auto highlighting for a specific level
    #primary.auto_highlight = false
  end
end
