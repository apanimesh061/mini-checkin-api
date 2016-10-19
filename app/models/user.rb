class User < ActiveRecord::Base
  has_many :check_ins
  has_many :businesses, :through => :check_ins
  has_many :unique_businesses, -> { uniq }, :through => :check_ins, :source => :business

  def last_check_in_at(business)
    CheckIn.where(user: self)
           .where(business: business)
           .last
  end
end
