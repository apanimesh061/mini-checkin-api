require 'spec_helper'

describe Business do

  it 'can be created' do
    business = create :business
    expect(business).to_not be_nil
  end

  it { should have_many :check_ins }
  it { should have_many :customers }
  it { should have_many :unique_customers }
  it { should have_db_column(:check_in_timeout).with_options(default: 3600) }

  describe '#before_create' do
    it 'calls #update_token' do
      business = build :business
      expect(business).to receive(:update_token)
      business.save 
    end
  end

  describe '#update_token' do
    it 'assigns a new base-64, url-safe string to the token field' do
      business = build :business
      expect{ business.update_token }.to change(business, :token).from(nil).to(String)
    end

    it 'updates the record if the record has already been created' do
      business = create :business
      expect(business).to receive(:save)
      business.update_token
    end 

    it 'does not save if the record has not yet been created' do
      business = build :business
      business.update_token
      expect(business.persisted?).to be_falsey
    end
  end

end
