class AddInviteCodeToAgentInviteSellerHistroys < ActiveRecord::Migration
  def change
    add_column :agent_invite_seller_histroys, :invite_code, :string
  end
end
