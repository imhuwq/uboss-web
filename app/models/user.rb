#encoding:utf-8
class User < ActiveRecord::Base
  validates :phone, presence: true, 
    :format=> {:with=> /^(\+\d+-)?[1-9]{1}[0-9]{10}$/, :message=> "手机格式不正确"}
end
