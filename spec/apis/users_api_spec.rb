require 'spec_helper'

def app
  ApplicationApi
end

describe UsersApi do
  include Rack::Test::Methods

  describe 'GET /users/:id/checkins' do
    it 'retreives the CheckIns associated with the User' do
    end

    context 'given a "limit" parameter' do
      it 'retreives only the last "n" CheckIns associated with the User' do
      end
    end
  end

  describe 'GET /users/:id/businesses' do
    let(:user) { create :user }
    let(:path) { "/users/#{user.id}/businesses" }

    it 'retrieves the Businesses associated with each of the User\'s CheckIns' do
      allow(User).to receive(:find).and_return(user)
      expect(user).to receive(:businesses).and_return([])
      get path, {}
    end

    context 'given a "unique" parameter' do
      it 'retreives the set of Businesses where a User has checked in' do
        allow(User).to receive(:find).and_return(user)
        expect(user).to receive(:unique_businesses).and_return([])
        get path, {
        	unique: true
        }
      end
    end 
  end

end
