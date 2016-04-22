# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.precompile += %w(
desktop.css desktop.js admin.js admin.css login.js login.css mobile.css mobile.js
marketing.css redactor-rails/* marketing.js
admin/sku_app/application.js mobile_page/chat_app/boot.js
mobile_page/menus/boot
hongbao.js hongbao.css
pages/bonus_invite.js
pages/bonus_invite.css
iscroll/iscroll.js
activate/activate.js
activate/activate.css
activate_page/nologin.jpg
mobile/store/choujiang.png
)
