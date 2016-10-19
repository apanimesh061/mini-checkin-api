class CheckIn < ActiveRecord::Base
  belongs_to :user
  belongs_to :business

  validates :user_id, :business_id, :presence => true
end
