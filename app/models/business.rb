class Business < ActiveRecord::Base
  has_many :check_ins
  has_many :customers, :through => :check_ins, :source => :user
  has_many :unique_customers, -> { uniq }, :through => :check_ins, :source => :user

  before_create :update_token

  def update_token(new_token = generate_token)
    self.token = new_token
    save unless id.nil?
  end

    private

  def generate_token
    SecureRandom.urlsafe_base64
  end
end
