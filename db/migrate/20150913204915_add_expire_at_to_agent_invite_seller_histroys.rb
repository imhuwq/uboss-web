class AddExpireAtToAgentInviteSellerHistroys < ActiveRecord::Migration
  def change
    add_column :agent_invite_seller_histroys, :expire_at, :datetime
  end
end
