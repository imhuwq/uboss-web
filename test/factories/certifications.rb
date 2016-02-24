FactoryGirl.define do
  factory :certification do

  end

  factory :personal_authentication do
    status 'posted'
    name 'heihei'
    province_code '130100'
    city_code '130100'
    mobile '19802020303'
    address 'CHINA'
    identity_card_code '441622201212120303'
    face_with_identity_card_img 'face.jpg'
    identity_card_front_img 'id.jpg'
  end

  factory :enterprise_authentication do

  end

end
