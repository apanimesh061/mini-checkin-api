#Check-In API Service

1. [Creating API Skeleton](#creating-api-skeleton)
2. [GemFile Version Issue](#gemfile-version-issue)
3. [Installation of Dependencies](#installation-of-dependencies)
4. [Creating Database](#creating-database-mysql)
5. [Model Generation](#model-generation)
6. [Migration of Models](#migration-of-models-to-database)
7. [API Generation](#api-generation)
8. [Security](#security)
9. [Rspec Tests](#rspec-tests)
10. [Examples](#example-curl-calls)

- - -

This repository contains a minimal API that can be used to check-in at a business. Information and be sent or received using endpoints created using `napa`.

There are three basic endpoints:
1. Users
2. Business
3. Check In

Basically, a `user` will `check-in` at a `business`.

####Creating API Skeleton

```
napa new belly-checkin-api
cd belly-checkin-api
```

####GemFile Version Issue
The `GemFile` present initially would look like this:
```
source 'https://rubygems.org'
ruby "2.0.0"

gem 'rack-cors'
gem 'mysql2'
gem 'activerecord', '~> 4.0.0', :require => 'active_record'
gem 'hashie-forbidden_attributes'
gem 'honeybadger', '~> 1.16.7'
gem 'json'
gem 'napa'
gem 'roar', '~> 0.12.0'
gem 'grape-swagger'

group :development,:test do
  gem 'pry'
end

group :development do
  gem 'rubocop', require: false
  gem 'shotgun', require: false
end

group :test do
  gem 'factory_girl'
  gem 'rspec'
  gem 'rack-test'
  gem 'simplecov'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
end
```
There are compatibilty issues between `ruby`, `activerecord` and `napa` as result of which it better to specify the versions. The final `GemFile` would look something like this:
```
source 'https://rubygems.org'
ruby "2.3.1"

gem 'rack-cors'
gem 'mysql2'
gem 'activerecord', '~> 4.2.0', :require => 'active_record'
gem 'hashie-forbidden_attributes'
gem 'honeybadger', '~> 1.16.7'
gem 'json'
gem 'napa', '~> 0.5.0'
gem 'roar', '~> 0.12.0'
gem 'grape-swagger'

group :development,:test do
  gem 'pry'
end

group :development do
  gem 'rubocop', require: false
  gem 'shotgun', require: false
end

group :test do
  gem 'factory_girl'
  gem 'rspec'
  gem 'rack-test'
  gem 'simplecov'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
end
```

####Installation of dependencies
```
bundle install
```

####Creating Database (MySQL)
By default `napa` uses *MySQL* as it database.

There are two files we are concerned with:
1. .env
2. config/database.yml

You could specify the database configuration details in `database.yml` or add them in `.env` file.
**NOTE:** `.env` in the root of the directory. Create the file if not generated.

After configuring we need to create the database. `napa` uses `rake` for this.

**ISSUE:** `napa` depends on `rake 10.3` and by default `ruby 2.3.1` installs `rake 10.4.2` which results in version conflict issues. So, don't directly run `rake db:create` rather append `bundle exec` to it.

```
bundle exec rake db:create
```
This will create a DB with name specified in `.env` file.


####Model Generation
Now that we have create our database, we have to decide how the tables will look like. For this we create models using `napa` and then migrate them to created database using `rake`. We can use the `napa generate` command for this.

First we'll create a `User` which has nothing but an `id` for simplicity purposes.
```
bundle exec napa generate model User
```


Then, we'll create a `Business` which has an `id`, `token` (for access) and a `check_in_timeout`.
```
bundle exec napa generate model Business token:string check_in_timeout:integer
```

Now, we'll create a `CheckIn` which is dependent on a `User` and a `Business`, so we have to add references of `user_id` and `business_id`.
```
bundle exec napa generate model CheckIn
bundle exec napa generate migration AddUserRefToCheckIns user:references
bundle exec napa generate migration AddBusinessRefToCheckIns business:references
```

####Migration of models to Database
We use command `bundle exec rake db:migrate` to start the migration. After migration DB looks like this:
```
mysql> show databases;
+-----------------------------------+
| Database                          |
+-----------------------------------+
| information_schema                |
| belly_checkin_api_development     |
| mysql                             |
| performance_schema                |
| sys                               |
+-----------------------------------+
6 rows in set (0.00 sec)

mysql> use belly_checkin_api_development;
Database changed

mysql> show tables;
+-----------------------------------------+
| Tables_in_belly_checkin_api_development |
+-----------------------------------------+
| businesses                              |
| check_ins                               |
| schema_migrations                       |
| users                                   |
+-----------------------------------------+
4 rows in set (0.00 sec)

mysql> desc businesses;
+------------------+--------------+------+-----+---------+----------------+
| Field            | Type         | Null | Key | Default | Extra          |
+------------------+--------------+------+-----+---------+----------------+
| id               | int(11)      | NO   | PRI | NULL    | auto_increment |
| token            | varchar(255) | YES  |     | NULL    |                |
| check_in_timeout | int(11)      | YES  |     | NULL    |                |
| created_at       | datetime     | YES  |     | NULL    |                |
| updated_at       | datetime     | YES  |     | NULL    |                |
+------------------+--------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> desc users;
+------------+----------+------+-----+---------+----------------+
| Field      | Type     | Null | Key | Default | Extra          |
+------------+----------+------+-----+---------+----------------+
| id         | int(11)  | NO   | PRI | NULL    | auto_increment |
| created_at | datetime | YES  |     | NULL    |                |
| updated_at | datetime | YES  |     | NULL    |                |
+------------+----------+------+-----+---------+----------------+
3 rows in set (0.00 sec)

mysql> desc check_ins;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| id          | int(11)  | NO   | PRI | NULL    | auto_increment |
| created_at  | datetime | YES  |     | NULL    |                |
| updated_at  | datetime | YES  |     | NULL    |                |
| user_id     | int(11)  | YES  | MUL | NULL    |                |
| business_id | int(11)  | YES  | MUL | NULL    |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)
```
- - -

####API Generation
Now that we have the models with us, we need to start thinking of how to get data into and from the database. This is done by using apis. Since, we have three by operation we need to create three endpoints
```
bundle exec napa generate api user
bundle exec napa generate api business
bundle exec napa generate api checkin
```
This generates three api files in `app/apis`.

You can add validations and customizations to api the way you want.

- - -


####Security
Here three possibilities have been considered:

1. Stopping malicious loggin-in by providing access only using a `token` that the user get when he creates a business
2. Second level of security could be provided using header passwords which can activated by adding `use Napa::Middleware::Authentication` to `config.ru`. The passwords are added in `.env` file as `ALLOWED_HEADER_PASSWORDS='sithlord'`
3. Stopping mis-use of the API. We can stop a user from frequently checking in the same business but providing a timeout.

- - -

####Rspec Tests
`rspec` tests have also been added to this project. You need to set-up a testing environment using `.env.test` and switch to Test Env by `RACK_ENV=test`.

Following commands need to be run in order to execute the tests:
```
RACK_ENV=test bundle exec rake db:create
RACK_ENV=test bundle exec rake db:migrate
bundle exec rspec spec
```
The output should give 0 failures.

**ISSUE:** There is an issue with some function references `NoMethodError` in the new `shoulda-matchers v3.1.1`. That can be resolved by downgrading to `v2.8.0`. This is been specified in the GemFile.

- - -

####Example Curl Calls

######User API

Creating a user
```
curl -X POST http://localhost:9393/users/ -H "Passwords: sithlord" -d '' | jq ''
{
  "data": {
    "object_type": "user",
    "id": "1"
  }
}
```

Creating a new user w/o header password raises an error
```
curl -X POST http://localhost:9393/users/ -d '' | jq ''
{
  "error": {
    "code": "bad_password",
    "message": "bad password"
  }
}
```

Create a new second user
```
curl -X POST http://localhost:9393/users/ -H "Passwords: sithlord" -d '' | jq ''
{
  "data": {
    "object_type": "user",
    "id": "2"
  }
}
```

Retrive all users
```
curl -X GET http://localhost:9393/users -H "Passwords: sithlord" | jq ''
{
  "data": [
    {
      "object_type": "user",
      "id": "1"
    },
    {
      "object_type": "user",
      "id": "2"
    }
  ]
}
```

- - -
######Business API

The `Base-64` code is generated using `SecureRandom`
```
curl -X POST http://localhost:9393/businesses/ -H "Passwords: sithlord" -d check\_in\_timeout=600 -d token="" | jq ''
{
  "data": {
    "object_type": "business",
    "id": "1",
    "token": "dQTL4FA7y_6hQnnDP30JDA"
  }
}

curl -X POST http://localhost:9393/businesses/ -H "Passwords: sithlord" -d check\_in\_timeout=600 -d token="" | jq ''
{
  "data": {
    "object_type": "business",
    "id": "2",
    "token": "c822trHuE-TAirjlXr-6Zg"
  }
}

+----+------------------------+------------------+---------------------+---------------------+
| id | token                  | check_in_timeout | created_at          | updated_at          |
+----+------------------------+------------------+---------------------+---------------------+
|  1 | dQTL4FA7y_6hQnnDP30JDA |              600 | 2016-10-19 15:43:00 | 2016-10-19 15:43:00 |
|  2 | c822trHuE-TAirjlXr-6Zg |              600 | 2016-10-19 15:46:48 | 2016-10-19 15:46:48 |
+----+------------------------+------------------+---------------------+---------------------+
```

After we have created a business, we can change the token using the following:
```
curl -X PUT http://localhost:9393/businesses/2/update_token -H "Passwords: sithlord" -d check\_in\_timeout=600 -d token="my_password" | jq ''
{
  "data": {
    "object_type": "business",
    "id": "2",
    "token": "my_password"
  }
}

+----+------------------------+------------------+---------------------+---------------------+
| id | token                  | check_in_timeout | created_at          | updated_at          |
+----+------------------------+------------------+---------------------+---------------------+
|  1 | dQTL4FA7y_6hQnnDP30JDA |              600 | 2016-10-19 15:43:00 | 2016-10-19 15:43:00 |
|  2 | my_password            |              600 | 2016-10-19 15:46:48 | 2016-10-19 15:49:43 |
+----+------------------------+------------------+---------------------+---------------------+
```

Retrieve all businesses
```
curl -X GET http://localhost:9393/businesses -H "Passwords: sithlord" | jq ''
{
  "data": [
    {
      "object_type": "business",
      "id": "1",
      "token": "dQTL4FA7y_6hQnnDP30JDA"
    },
    {
      "object_type": "business",
      "id": "2",
      "token": "my_password"
    }
  ]
}
```

- - -
######CheckIn API

```
curl -X POST http://localhost:9393/checkins -H "Passwords: sithlord" -d user\_id=1 -d business\_id=1 -d business\_token="my_password" | jq ''
{
  "error": {
    "code": "api_error",
    "message": "Invalid token"
  }
}

curl -X POST http://localhost:9393/checkins -H "Passwords: sithlord" -d user\_id=1 -d business\_id=2 -d business\_token="my_password" | jq ''
{
  "data": {
    "object_type": "check_in",
    "id": "1"
  }
}
```

If we try to check-in before the timeout of 600s, we get an error
```
curl -X POST http://localhost:9393/checkins -H "Passwords: sithlord" -d user\_id=1 -d business\_id=2 -d business\_token="my_password" | jq ''
{
  "error": {
    "code": "api_error",
    "message": "You are checkin-in too frequently"
  }
}

+----+---------------------+---------------------+---------+-------------+
| id | created_at          | updated_at          | user_id | business_id |
+----+---------------------+---------------------+---------+-------------+
|  1 | 2016-10-19 15:52:00 | 2016-10-19 15:52:00 |       1 |           2 |
+----+---------------------+---------------------+---------+-------------+
1 row in set (0.00 sec)
```

####Misc
The whole code was run on an Ubuntu 16.04 Docker Image on a Windows 10 host
