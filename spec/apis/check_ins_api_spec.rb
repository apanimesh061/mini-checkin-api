require 'spec_helper'

def app
  ApplicationApi
end

describe CheckInsApi do
  include Rack::Test::Methods

  describe CreateCheckIn do
    let(:user) { create :user }
    let(:business) { create :business }
    let(:token) { business.token }

    describe '#call' do

      context 'given valid user, business, and token' do
        let(:action) do
          args = { user: user, business: business, business_token: token }
          CreateCheckIn.new(args)  
        end

        it 'returns a truthy value' do
          result = action.call

          expect(result).to be_truthy
        end

        it 'creates a new CheckIn record' do
          expect{ action.call }.to change{ CheckIn.count }.by(1)
        end

        it 'stores its CheckIn record as an attribute' do
          action.call

          expect(action.record).to be_a CheckIn
        end

        it 'will not create duplicate records' do
          action.call

          expect{ action.call }.to_not change{ CheckIn.count }
        end

        it 'stores no errors' do
          action.call

          expect(action.errors.empty?).to be true
        end
      end
    end

    describe '#valid?' do

      context 'given too small of a time between check_ins' do
        let(:business) { create :business, check_in_timeout: 10000 }
        let(:args) {{ user: user, business: business, business_token: token}}
        let(:action) { CreateCheckIn.new(args) }

        it 'returns false' do
          create :check_in, user: user, business: business

          expect(action.valid?).to be_falsey
        end

        it 'has a corresponding error' do
          create :check_in, user: user, business: business
          action.valid?

          # could couple test to specific message
          expect(action.errors.empty?).to be_falsey 
        end
      end

      context 'given an invalid token' do
        let(:args) {{ user: user, business: business, business_token: "FOO!" }}
        let(:action) { CreateCheckIn.new(args) }

        it 'returns false' do
          expect(action.valid?).to be_falsey
        end

        it 'has a corresponding error' do
          action.valid?

          expect(action.errors.empty?).to be_falsey
        end
      end

      context 'given a non-existing user' do
        let(:args) {{ user: "FOO!", business: business, business_token: token }}
        let(:action) { CreateCheckIn.new(args) }

        it 'returns false' do
          expect(action.valid?).to be_falsey
        end

        it 'has a corresponding error' do
          action.valid?

          expect(action.errors.empty?).to be_falsey
        end
      end

      context 'given a non-existent business' do
        let(:args) {{ user: user, business: "FOO!", business_token: token }}
        let(:action) { CreateCheckIn.new(args) }

        it 'returns false' do
          expect(action.valid?).to be_falsey
        end

        it 'has a corresponding error' do
          action.valid?

          expect(action.errors.empty?).to be_falsey
        end
      end

    end
  end

  describe 'POST /checkins' do
    let(:user) { create :user }
    let(:business) { create :business }

    context 'given valid parameters' do
      it 'returns a JSON string with the new check-in data' do
        args = { 
          user_id: user.id, 
          business_id: business.id, 
          business_token: business.token 
        }
        post '/checkins', args

        expect(response_body).to match(/data.*id.*/)
      end
    end

    context 'given invalid parameters' do
      it 'returns an error message' do
        args = { 
          user_id: user.id, 
          business_id: business.id, 
          business_token: "Jedi"
        }
        post '/checkins', args

        expect(response_body).to match(/error.*message/)
      end
    end

    it 'requires user_id' do
      args = { 
        business_id: business.id, 
        business_token: business.token 
      }
      post '/checkins', args

      expect(response_body).to match(/error.*message.*user_id/)
    end

    it 'requires business_id' do
      args = { 
        user_id: user.id, 
        business_token: business.token 
      }
      post '/checkins', args

      expect(response_body).to match(/error.*message.*business_id/)
    end

    it 'requires a business_token' do
      args = { 
        user_id: user.id, 
        business_id: business.id 
      }
      post '/checkins', args
      
      expect(response_body).to match(/error.*message.*business_token/)
    end
  end

end
