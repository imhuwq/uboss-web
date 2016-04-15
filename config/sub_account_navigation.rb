SimpleNavigation::Configuration.run do |navigation|

  navigation.renderer = UbossNavRenderer

  navigation.active_leaf_class = 'actived-leaf'

  navigation.id_generator = Proc.new {|key| "admin-nav-#{key}"}


  # Define the primary navigation
  navigation.items do |primary|

    primary.item :main,   '主页', admin_root_path,             {}

    primary.item :tuangou, '本地服务', '#', {} do |sub_nav|
      sub_nav.item :s_product, '商品', admin_service_products_path,
        highlights_on: :subpath, if: -> { can?(:read, ServiceProduct) }

      sub_nav.item :s_verify,  '验证', admin_verify_codes_path,
        highlights_on: :subpath, if: -> { can?(:manage, VerifyCode) }

      sub_nav.item :s_calling,  '服务', '#' do |thr_nav|
        thr_nav.item :calling_services, '呼叫服务', admin_calling_notifies_path, highlights_on: :subpath, if: -> { can?(:manage, CallingNotify) }
        thr_nav.item :service_setting, '服务设置', admin_calling_services_path, highlights_on: :subpath,if: -> { can?(:manage, CallingNotify) }
      end

      sub_nav.item :s_pj,      '评价', admin_evaluations_path,
        highlights_on: :subpath, if: -> { can?(:manage, Evaluation) }

      sub_nav.item :s_store,   '设置', edit_admin_service_store_path(current_account.service_store) do |thr_nav|
        thr_nav.item :edit_store, '店铺设置', edit_admin_service_store_path(current_account.service_store),
          if: -> { can?(:manage, ServiceStore) }
      end
    end
  end
end
