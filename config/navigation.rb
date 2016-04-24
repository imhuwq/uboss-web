# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  navigation.renderer = UbossNavRenderer

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
    primary.item :income, '收益', '#' do |sub_nav|
      sub_nav.item :withdraws, '提现', admin_withdraw_records_path, highlights_on: :subpath,
        if: -> { can?(:read, WithdrawRecord) }
      sub_nav.item :bank_cards, '银行卡', admin_bank_cards_path, highlights_on: :subpath,
        if: -> { can?(:read, BankCard) }
    end
    primary.item :agent,  'U客',  admin_sellers_path, if: -> { can?(:read, :sellers) }
    primary.item :operator, '运营商', '#' do |sub_nav|
      sub_nav.item :operators, '运营商', admin_operators_path,
        highlights_on: -> { params[:controller] == 'admin/operators' && params[:action] == 'index' },
        if: -> { can?(:manage, Operator) }

      sub_nav.item :new_operator, '权限管理', users_admin_operators_path,
        if: -> { can?(:manage, Operator) }

      if can?(:manage, Shop) && operator=current_user.operator
        sub_nav.item :shop, '商家营收', admin_operator_shops_path(operator),
        if: -> { can?(:manage, Shop) }

        sub_nav.item :new_shop, '新增商家', added_admin_operator_shops_path(operator),
          highlights_on: %r(shops/added|shops/new),
          if: -> { can?(:manage, Clerk) }
      end
    end

    # Add an item which has a sub navigation (same params, but with block)
    primary.item :seller, '电商店铺', admin_products_path do |sub_nav|
      # Add an item to the sub navigation (same params again)
      sub_nav.item :products, '商品', admin_products_path, {} do |thr_nav|
        thr_nav.item :new_products, '商品', admin_products_path,
          highlights_on: :subpath, if: -> { can?(:read, Product) }

        thr_nav.item :new_products, '运费模板', admin_sellers_carriage_templates_path,
          highlights_on: :subpath, if: -> { can?(:read, CarriageTemplate) }

        thr_nav.item :new_products, '商品分组', admin_categories_path(dishes: false),
          highlights_on: :subpath, if: -> { can?(:read, Category) && params[:dishes] !='true' }
      end
      sub_nav.item :order,  '订单', '#' do |thr_nav|
        thr_nav.item :orders, '订单', admin_orders_path,
          highlights_on: :subpath, if: -> { can?(:read, Order) }

        thr_nav.item :orders, '快递', admin_expresses_path,
          highlights_on: :subpath, if: -> { can?(:read, Express) }

        thr_nav.item :orders, '地址库', admin_user_addresses_path,
          highlights_on: :subpath, if: -> { can?(:manage, UserAddress) }
      end
      sub_nav.item :store,  '设置', admin_store_path(current_user) do |thr_nav|
        thr_nav.item :edit_store, '店铺设置', edit_admin_stores_path,
          if: -> { can?(:read, Product) }
      end
      sub_nav.item :stock, '市场进货', "#", if: -> { can?(:manage, :agency_product) } do |thr_nav|
        thr_nav.item :valid_agent_products, '可代销商品', admin_sellers_valid_agent_products_path,
          highlights_on: :subpath, if: -> { can?(:manage, :agency_product) }

        thr_nav.item :my_suppliers, '我的供货商', my_suppliers_admin_sellers_path,
          highlights_on: :subpath, if: -> { can?(:manage, :agency_product) }
      end
    end

    primary.item :tuangou, '本地服务', '#', {} do |sub_nav|
      sub_nav.item :s_product, '商品', admin_service_products_path,
        highlights_on: :subpath, if: -> { can?(:read, ServiceProduct) }

      sub_nav.item :s_verify,  '验证', '#' do |thr_nav|
        thr_nav.item :verify_codes, '验证管理', admin_verify_codes_path, highlights_on: :subpath, if: -> { can?(:manage, VerifyCode) }
        thr_nav.item :verify_codes, '收银管理', admin_bill_orders_path, highlights_on: :subpath, if: -> { can?(:manage, BillOrder) }
      end

      sub_nav.item :s_dishes,  '菜品', admin_dishes_products_path, {} do |thr_nav|
        thr_nav.item :new_dishes, '菜品', admin_dishes_products_path,
          highlights_on: :subpath, if: -> { can?(:read, DishesProduct) }

        thr_nav.item :new_dishes, '分组管理', admin_categories_path(dishes: true),
          highlights_on: :subpath, if: -> { can?(:read, Category) && params[:dishes] != 'false' }
      end

      sub_nav.item :s_calling,  '服务', '#' do |thr_nav|
        thr_nav.item :calling_services, '呼叫服务', admin_calling_notifies_path, highlights_on: :subpath, if: -> { can?(:manage, CallingNotify) }
        thr_nav.item :service_setting, '服务设置', admin_calling_services_path, highlights_on: :subpath,if: -> { can?(:manage, CallingNotify) }
      end

      sub_nav.item :s_pj,      '评价', admin_evaluations_path,
        highlights_on: :subpath, if: -> { can?(:manage, Evaluation) }

      sub_nav.item :s_income,  '收益', income_detail_admin_service_stores_path,
        highlights_on: %r(admin/service_stores/income_detail|admin/service_stores/statistics),
        if: -> { can?(:manage, :income) }

      sub_nav.item :s_store,   '设置', edit_admin_service_store_path(current_user.service_store) do |thr_nav|
        thr_nav.item :edit_store, '店铺设置', edit_admin_service_store_path(current_user.service_store),
          if: -> { can?(:manage, ServiceStore) }
        thr_nav.item :sstore_sub_account, '子账号', admin_sub_accounts_path, highlights_on: :subpath,
          if: -> { can?(:create, SubAccount) }
      end
    end

    primary.item :supplier, '我要供货', '#' do |sub_nav|
      sub_nav.item :new_supplier_store, '创建供货店铺', new_admin_supplier_store_path, if: -> { can? :new, SupplierStore }
      sub_nav.item :agency, '代销商', admin_agencies_path, if: -> { can?(:read, :agencies) } do |thr_nav|
        thr_nav.item :agencies, '我的代销商', admin_agencies_path,
          if: -> { can?(:read, :agencies) }
        thr_nav.item :new_agency, '发展代销商', new_admin_agency_path,
          if: -> { can?(:read, :agencies) }
      end
      sub_nav.item :supplier_product, '商品', admin_supplier_products_path, if: -> { can?(:manage, SupplierProduct) } do |thr_nav|
        thr_nav.item :supplied_products, '代销中', admin_supplier_products_path(status: 'supply'), highlights_on: -> { params[:status] == 'supply' }, if: -> { can?(:manage, SupplierProduct) }
        thr_nav.item :stored_products, '仓库中', admin_supplier_products_path(status: 'store'), highlights_on: -> { params[:status] == 'store' }, if: -> { can?(:manage, SupplierProduct) }
        thr_nav.item :new_products, '运费模板', admin_suppliers_carriage_templates_path,
          highlights_on: :subpath, if: -> { can?(:read, CarriageTemplate) }
      end
      sub_nav.item :purchase_orders, '订单管理', admin_purchase_orders_path,
        if: -> { can?(:manage, PurchaseOrder) }
    end

    primary.item :promotion_activity, '商家活动', '#', {} do |sub_nav|
      sub_nav.item :s_published_activities, '参与中', admin_promotion_activities_path(type: 'published'),
        highlights_on: -> { params[:type] == 'published' && controller_name == 'promotion_activities'},
        if: -> { can?(:read, PromotionActivity) }

      sub_nav.item :s_unpublish_activities, '已下架', admin_promotion_activities_path(type: 'unpublish'),
        highlights_on: -> { params[:type] == 'unpublish' && controller_name == 'promotion_activities'},
        if: -> { can?(:read, PromotionActivity) }
    end

    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    primary.item :uboss, 'UBOSS', '#', class: 'special' do |sub_nav|
      sub_nav.item :uboss_ops, '运营', admin_agents_path, if: -> { can?(:manage, :agents) } do |thr_nav|
        thr_nav.item :agents, '创客', admin_agents_path,
          highlights_on: :subpath, if: -> { can?(:manage, :agents) }

        thr_nav.item :certifications, '认证', persons_admin_certifications_path,
          highlights_on: -> { controller_name.match(/authentications|certifications/).present? },
          if: -> { can?(:manage, :authentications) }

        thr_nav.item :platform_ads, '平台广告', admin_platform_advertisements_path,
          highlights_on: :subpath, if: -> { can?(:manage, :platform_advertisements) }

        thr_nav.item :wechat_acccount, '微信账户', admin_wechat_accounts_path,
          highlights_on: :subpath, if: -> { can?(:manage, WechatAccount) }
      end
      sub_nav.item :financial, '财务', admin_transactions_path, if: -> { can?(:manage, Transaction) } do |thr_nav|
        thr_nav.item :transactions, '交易明细', admin_transactions_path,
          highlights_on: :subpath, if: -> { can?(:manage, Transaction) }
        thr_nav.item :sharing_incomes, '分享分成', admin_sharing_incomes_path,
          highlights_on: :subpath, if: -> { can?(:manage, SharingIncome) }
      end
      sub_nav.item :users, '账户管理', admin_users_path,
        highlights_on: -> { controller_name.match(/users/).present? },
        if: -> { can?(:handle, User) }

      sub_nav.item :backend_status, '后台队列', admin_backend_status_path, if: -> { can?(:manage, :backend_status) }
    end
    #primary.item :agency,   '我的代销商', admin_my_agencies_path, {}
    #primary.item :my_supplier,   '我的供应商', my_suppliers_admin_sellers_path, {}

    # you can also specify html attributes to attach to this particular level
    # works for all levels of the menu
    #primary.dom_attributes = {id: 'menu-id', class: 'menu-class'}

    # You can turn off auto highlighting for a specific level
    #primary.auto_highlight = false
  end
end
