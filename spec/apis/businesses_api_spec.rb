require 'spec_helper'

def app
  ApplicationApi
end

describe BusinessesApi do
  include Rack::Test::Methods

  describe 'PUT /businesses/:id/' do
    let(:business) { create :business }
    let(:path) { "/businesses/#{business.id}" }

    it 'calls to update the business with given attributes' do
      allow(Business).to receive(:find).and_return(business)
      args = { check_in_timeout: 6000 }

      expect(business).to receive(:update_attributes!)
      put path, args
    end
  end

  describe 'PUT /businesses/:id/update_token' do
    let(:business) { create :business }
    let(:path) { "/businesses/#{business.id}/update_token" }

    context 'given an optional token parameter' do
      it 'calls #update_token with the token parameter' do
        token = "Jedi"
        args = { token: token }
        allow(Business).to receive(:find).and_return(business)

        expect(business).to receive(:update_token).with(token)
        put path, args
      end
    end

    context 'not given an optional token parameter' do
      it 'calls #update_token with nil' do
        args = {}
        allow(Business).to receive(:find).and_return(business)

        expect(business).to receive(:update_token).with(nil)
        put path, args
      end
    end
  end

  describe 'GET /businesses/:id/checkins' do
    let(:business) { create :business }
    let(:path) { "/businesses/#{business.id}/checkins" }

    context 'given no parameters' do
      it 'retreives associated CheckIns' do
        allow(Business).to receive(:find).and_return(business)

        expect(business).to receive(:check_ins).and_return([])
        get path, {}
      end
    end

    context 'given a "limit" parameter' do
      it 'retreives the last "n" CheckIns' do
        allow(Business).to receive(:find).and_return(business)

        expect(business).to receive_message_chain(:check_ins, :last).and_return([])
        get path, {limit: 5}
      end
    end
  end
  
  describe 'GET /businesses/:id/customers' do
  	
    let(:business) { create :business }
    let(:path) { "/businesses/#{business.id}/customers" }

    it 'retreives the Users associated with previous CheckIns' do
      allow(Business).to receive(:find).and_return(business)

      expect(business).to receive(:customers).and_return([])
      get path, {}
    end

    context 'given a "unique" parameter' do
      it 'retreives unique User records associated with previous CheckIns' do
        allow(Business).to receive(:find).and_return(business)

        expect(business).to receive(:unique_customers).and_return([])
        get path, {unique: true}
      end
    end

  end

end
