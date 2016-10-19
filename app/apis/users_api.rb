class UsersApi < Grape::API

  helpers do
    def user
      @user ||= User.find(params[:id])
    end
  end

  desc 'Get a list of users'
  params do
    optional :ids, type: Array, desc: 'Array of user ids'
  end
  get do
    users = params[:ids] ? User.where(id: params[:ids]) : User.all
    represent users, with: UserRepresenter
  end

  desc 'Create a user'
  post do
    new_user = User.create!
    represent new_user, with: UserRepresenter
  end

  params do
    requires :id, desc: 'ID of the user'
  end
  route_param :id do
    desc 'Get a user'
    get do
      represent user, with: UserRepresenter
    end

    desc 'Get a list of Businesses where the User has checked in'
    params do
      optional :unique, type: Boolean, desc: "Only list each Business once"
    end
    get '/businesses' do
      if permitted_params[:unique]
        businesses = user.unique_businesses
      else
        businesses = user.businesses
      end
      represent businesses, with: BusinessRepresenter
    end

    desc 'Get a list of CheckIns by a User'
    params do
      optional :limit, type: Integer, desc: "Number of most recent CheckIns desired"
    end
    get '/checkins' do
      if permitted_params[:limit]
        check_ins = user.check_ins.last(permitted_params[:limit])
      else
        check_ins = user.check_ins
      end
      represent check_ins, with: CheckInRepresenter
    end
  end

end
