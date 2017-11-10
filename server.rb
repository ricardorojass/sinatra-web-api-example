require 'sinatra'
require 'json'

# get '/users'
# post '/users'

# Endpoints
get '/ ' do
  'Welcome to Sinatra Api!'
end

# Serializers
class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    data = {
      name:@user.name.to_s
    }
    data
  end
end

set :bind, '0.0.0.0'

configure do
  enable :cross_origin
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options '*' do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] =
  "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

users = {
  'richi': { name: 'Ricardo' },
  'rogeiro': { name: 'Roger' },
  'pablito': { name: 'Pablo' }
}

helpers do

  def send_data(data = {})
    if type == 'json'
      contend_type 'application/json'
      data[:json].call.to_json if data[:json]
    end
  end

  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
end

get '/users' do
  users.map { |name, data| data.merge(id: name) }.to_json
end

post '/users' do
  halt 415 unless request.env['CONTENT_TYPE'] == 'application/json'
  user = json_params
  puts user
  puts user.empty?
  unless user['name'].empty?
    users[user['name'].downcase.to_sym] = user
    response.headers['Location'] = "http://localhost:4567/users/#{user['name']}"
    status 201
    JSON.generate(user)
  else
    status 422
    body UserSerializer.new(user).to_json
  end


end
