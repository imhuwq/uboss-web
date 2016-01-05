class ChangeUserLoginDefaultAndNull < ActiveRecord::Migration
  def up
    change_column_default :users, :login, nil
    change_column_null :users, :login, true
  end
end
