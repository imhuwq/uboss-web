class CreateAgentInviteSellerHistroys < ActiveRecord::Migration
  def change
    create_table :
    agent_invite_seller_histroys do |t|
      t.string    :mobile
      t.integer   :agent_id
      t.integer   :seller_id
      t.integer   :status,  default: 0
      t.string    :note
      t.timestamps null: false
    end
  end
end
