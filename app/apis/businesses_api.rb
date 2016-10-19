class BusinessesApi < Grape::API

  helpers do
    # This is a helper function which returns
    # a business id if it exists
    # @param: None
    #
    def business
      @business ||= Business.find(params[:id])
    end
  end

  desc 'Get a list of businesses'
  # Here the API call expects nothing or
  # business id
  # #
  params do
    optional :ids, type: Array, desc: 'Array of business ids'
  end
  get do
    # This represents a GET request which returns a Business
    # for the id provided else it returns all businesses
    # #
    businesses = params[:ids] ? Business.where(id: params[:ids]) : Business.all
    represent businesses, with: BusinessRepresenter
  end

  desc 'Create a business'
  params do
    optional :check_in_timeout, type: Integer, desc: 'Seconds required between check-ins by a single User'
    optional :token, type: String, desc: 'Custom token to use for check-in verification'
  end
  post do
    business = Business.create(permitted_params)
    represent business, with: BusinessRepresenter
  end

  params do
    requires :id, desc: 'ID of the business'
  end
  route_param :id do
    desc 'Get an business'
    get do
      represent business, with: BusinessRepresenter
    end

    desc 'Update an business'
    params do
      optional :check_in_timeout, type: Integer, desc: 'Seconds required between check-ins by a single User'
    end
    put do
      business.update_attributes!(permitted_params)
      represent business, with: BusinessRepresenter
    end

    desc 'Reset the token for a Business'
    params do
      optional :token, type: String, desc: 'Token required to check-in at a Business'
    end
    put '/update_token' do
      business.update_token(permitted_params[:token])
      represent business, with: BusinessRepresenter
    end

    desc 'Get a list of CheckIns for a Business'
    params do
      optional :limit, type: Integer, desc: 'Number of most recent check-ins desired'
    end
    get '/checkins' do
      if permitted_params[:limit]
        check_ins = business.check_ins.last(permitted_params[:limit])
      else
        check_ins = business.check_ins
      end
      represent check_ins, with: CheckInRepresenter
    end

    desc 'Get a list of Users that have checked in at a Business'
    params do
      optional :unique, type: Boolean, desc: 'Only list each customer once'
    end
    get '/customers' do
      if permitted_params[:unique]
        customers = business.unique_customers
      else
        customers = business.customers
      end
      represent customers, with: UserRepresenter
    end
  end

end
