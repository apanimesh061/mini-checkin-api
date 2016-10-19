class AddBusinessRefToCheckIns < ActiveRecord::Migration
  def change
    add_reference :check_ins, :business, index: true
  end
end