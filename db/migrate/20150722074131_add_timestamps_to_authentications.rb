class AddTimestampsToAuthentications < ActiveRecord::Migration
  def change
    add_column :personal_authentications, :created_at, :datetime
    add_column :personal_authentications, :updated_at, :datetime
    add_column :enterprise_authentications, :created_at, :datetime
    add_column :enterprise_authentications, :updated_at, :datetime
  end
end
