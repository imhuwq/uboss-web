class ChangeAllFloatColumToDecimalAnyAboutMoney < ActiveRecord::Migration
  def change
    change_column :transactions, :current_amount, :decimal
    change_column :transactions, :adjust_amount, :decimal

    change_column :order_charges, :paid_amount, :decimal

    change_column :order_items, :pay_amount, :decimal
    change_column :order_items, :present_price, :decimal

    change_column :orders, :pay_amount, :decimal
    change_column :orders, :income, :decimal

    change_column :privilege_cards, :amount, :decimal

    change_column :products, :original_price, :decimal
    change_column :products, :present_price, :decimal
    change_column :products, :traffic_expense, :decimal
    change_column :products, :share_amount_total, :decimal
    change_column :products, :share_amount_lv_1, :decimal
    change_column :products, :share_amount_lv_2, :decimal
    change_column :products, :share_amount_lv_3, :decimal
    change_column :products, :share_rate_lv_1, :decimal
    change_column :products, :share_rate_lv_2, :decimal
    change_column :products, :share_rate_lv_3, :decimal
    change_column :products, :share_rate_total, :decimal
    change_column :products, :discount_amount, :decimal
    change_column :products, :privilege_amount, :decimal

    change_column :sharing_incomes, :amount, :decimal

    change_column :user_infos, :income, :decimal
    change_column :user_infos, :frozen_income, :decimal

    change_column :withdraw_records, :amount, :decimal
  end
end
