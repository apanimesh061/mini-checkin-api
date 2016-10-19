class AddUserRefToCheckIns < ActiveRecord::Migration
  def change
    add_reference :check_ins, :user, index: true
  end
end