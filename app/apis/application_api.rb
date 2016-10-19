class ApplicationApi < Grape::API
  format :json
  extend Napa::GrapeExtenders

  mount CheckInsApi => '/checkins'
  mount BusinessesApi => '/businesses'
  mount UsersApi => '/users'

  add_swagger_documentation
end
