class AddBounsBenefitToUser < ActiveRecord::Migration
  def change
    add_column :users, :bouns_benefit, :decimal, default: 0
  end
end
