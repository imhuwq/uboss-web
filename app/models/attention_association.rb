class AttentionAssociation < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id", :class_name => "User"
  belongs_to :following, :foreign_key => "following_id", :class_name => "User"
end
