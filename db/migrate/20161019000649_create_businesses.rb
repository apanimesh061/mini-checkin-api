class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :token
      t.integer :check_in_timeout

      t.timestamps
    end
  end
end