class CreateCheckIn
  attr_reader :record, :errors
  
  def initialize(args)
    @user = args[:user]
    @business = args[:business]
    @business_token = args[:business_token]
    @record = nil
  end

  def call
    return @record if @record
    if valid?
      @record = CheckIn.create(user: @user, business: @business)
    else
      false
    end
  end

  def valid?
    required_params? && valid_time? && valid_token?
  end

  def errors
    @errors ||= Array.new
  end

    private

  def required_params?
    if @user.is_a?(User) && @business.is_a?(Business) && @business_token.is_a?(String)
      true
    else
      append_error("Invalid parameters provided", 400)
      false
    end
  end

  def valid_token?
    if @business_token != @business.token
      append_error('Invalid token', 400)
      return false
    end
    true
  end
  
  def valid_time?
    if token_valid_at > Time.now
      append_error('You are checkin-in too frequently', 400)
      false
    else
      true
    end
  end

  def token_valid_at
    prev = @user.last_check_in_at @business
    if prev
      prev.created_at + @business.check_in_timeout
    else
      Time.now - 1
    end
  end

  def append_error(message = 'Bad request', code = 400)
    errors << { message: message, code: code }
  end
  
end


class CheckInsApi < Grape::API

  helpers do
    def user
      User.find_by_id permitted_params[:user_id]
    end

    def business
      Business.find_by_id permitted_params[:business_id]
    end

    def business_token
      permitted_params[:business_token]
    end
  end

  desc "Create a CheckIn"
  params do
    requires :user_id, type: Integer, desc: "ID of User checking in"
    requires :business_id, type: Integer, desc: "ID of Business where User is checking in"
    requires :business_token, type: String, desc: "Token string to check in at Business"
  end
  post do
    args = { user: user, business: business, business_token: business_token }
    @action = CreateCheckIn.new(args)

    if @action.call
      represent @action.record, with: CheckInRepresenter
    else
      action_error = @action.errors.first
      error! action_error[:message], action_error[:code]
    end
  end

end
