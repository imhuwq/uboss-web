module SessionsHelper

  def is_super_admin?
    if current_user.user_roles.collect(&:name).include?('super_admin')
      return true
    else
      return false
    end
  end

  def login_simple_captcha_components
    @login_simple_captcha_components ||= simple_captcha_options(
      refresh_button_html: { class: 'btn btn-primary', id: 'refresh_img_captcha_btn'},
      refresh_button_text: '刷新图片',
      input_html: {class: 'form-control'}
    )
  end

  def mobile_login_simple_captcha_components
    @login_simple_captcha_components ||= simple_captcha_options(
      refresh_button_html: { id: 'refresh_img_captcha_btn'},
    )
  end

end
