# UBOSS

## Geting Start

`cp config/database.yml.example config/database.yml`

Config your DB

`cp config/secrets.yml.example config/secrets.yml`

Config runing data, `upyun / weixin / product_sharing ....`

run
```shell
bundle install
bin/rake db:create && bin/rake db:migrate
bin/rake db:seed # genrate 2 admin user

# start your development server
bin/rails s

# start sidekiq for background job
bin/sidekiq
```

## Requires

- ruby 2.2.2
- DB `Postgresql & Redis`
- 微信支付需要下载 apiclient_cert.p12
- imagemagic

## 配置开发环境

查看Towering上的[这个文档](https://tower.im/projects/8a879141134a43159e31505c6e05e167/docs/5bc701ae5f1c4344b167b56ab0178d4c/)
