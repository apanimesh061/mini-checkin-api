require 'spec_helper'

describe User do

  it { should have_many :check_ins }
  it { should have_many :businesses }
  it { should have_many :unique_businesses }

  describe '#last_check_in_at' do
    let(:user) { create :user }

    it 'should return the User\'s most recent CheckIn at a given Business' do
      business = create :business
      ## Creating 50 users
      50.times {
      	CheckIn.create(user: user, business: business) 
      }
      check_in = CheckIn.create(user: user, business: business)
      last = user.last_check_in_at business

      expect(last).to eq check_in
    end

    it 'should return nil if the User has never checked in at given Business' do
      business = create :business
      last = user.last_check_in_at business

      expect(last).to be_falsey
    end
  end
  
end
