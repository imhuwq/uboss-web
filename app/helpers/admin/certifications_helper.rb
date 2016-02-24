module Admin::CertificationsHelper
  CERTIFICATIONS_TABS = {
    "个人认证"    => { action: "persons", resource: PersonalAuthentication },
    "企业认证"    => { action: "enterprises", resource: EnterpriseAuthentication },
    "城市运营商"  => { action: "city_managers", resource: CityManagerAuthentication }
  }

  CERTIFICATION_TABS =  {
    "个人认证" => { controller: 'admin/personal_authentications', resource: PersonalAuthentication },
    "企业认证" => { controller: 'admin/enterprise_authentications', resource: EnterpriseAuthentication },
    "城市运营商认证" => { controller: "admin/city_manager_authentications", resource: CityManagerAuthentication }
  }

  def link_to_certifications_tabs
    link_to_tabs(CERTIFICATIONS_TABS) do |name, option|
      is_current_action = params[:action] == option[:action]
      content_tag "div", "", class: "tab-title #{'active' if is_current_action }" do
        link_to_unless is_current_action,  name, option.merge(controller: 'admin/certifications')
      end
    end
  end

  def link_to_certification_tabs
    link_to_tabs(CERTIFICATION_TABS) do |name, option|
      is_current_action = params[:controller] == option[:controller]
      content_tag "div", "", class: "tab-title #{'active' if is_current_action }" do
        link_to_unless is_current_action,  name, option.merge(action: 'new')
      end
    end
  end

  def link_to_certification_edit_tabs
    link_to_tabs(CERTIFICATION_TABS) do |name, option|
      is_current_action = params[:controller] == option[:controller]
      content_tag "div", "", class: "tab-title #{'active' if is_current_action }" do
        link_to_unless is_current_action,  "编辑#{name}", option.merge(action: 'edit')
      end
    end
  end

  def link_to_tabs(options)
    options.reduce("") do |str, (name, option)|
      if can?(:create, option[:resource])
        str << yield(name, option.slice(:controller, :action))
      end
      raw(str)
    end
  end
end
