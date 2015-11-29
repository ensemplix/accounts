require 'sinatra/param'
require 'data_mapper'
require 'sinatra'
require 'bcrypt'
require 'json'

$TOKEN = ""

DataMapper.setup(:default, 'mysql://user:password@localhost/accounts')

class Account
  include DataMapper::Resource

  property :id, Serial
  property :username, String, :length => 15, :unique_index => true
  property :email, String, :length => 255, :format => :email_address
  property :password, BCryptHash
  property :session, String, :length => 15
  property :ip, IPAddress
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!
DataMapper.finalize

before do
  content_type :json
end

before do
  param :token, String, required: true

  unless params[:token].eql? $TOKEN
    halt 401, {:message => 'Parameter is invalid', :errors => {:token => 'Parameter is invalid'}}.to_json
  end
end

before do
  param :username, String, required: true, min_length: 3, max_length: 15
end

get '/register' do
  param :password, String, required: true, min_length: 5, max_length: 25
  param :email, String, required: true, min_length: 5
  param :ip, String, required: true, max_length: 39

  if Account.create(
      :username => params[:username],
      :password => BCrypt::Password.create(params[:password]),
      :email => params[:email],
      :ip => params[:ip]
  ).saved?
    {:success => 'Successfully created new account'}.to_json
  else
    halt 400, {:message => 'Account already exists'}.to_json
  end
end

post '/login' do
  param :password, String, min_length: 5, max_length: 25
  param :session, String, min_length: 15, max_length: 15
  param :remember, :boolean, default: false
  any_of :password, :session

  account = Account.first(:username => params[:username])

  if account.nil?
    halt 400, {:message => 'Account matching such username was not found'}.to_json
  end

  if params[:password].nil?
    if account.session.nil?
      halt 400, {:message => 'Account not using session'}.to_json
    end

    unless account.session.eql? params[:session]
      halt 401, {:message => 'Parameter is invalid', :errors => {:session => 'Parameter is invalid'}}.to_json
    end
  else
    unless account.password == params[:password]
      halt 401, {:message => 'Parameter is invalid', :errors => {:password => 'Parameter is invalid'}}.to_json
    end
  end

  @result = {:message => 'Succesfully login'}

  if params[:remember]
    session = SecureRandom.urlsafe_base64(15);
    account.update(:session => session)
    @result += {:session => session}
  end

  if params[:username].nil?
    @result += {:username => account[:username]}
  end

  @result.to_json
end

post '/logout' do
  param :session, String, required: true, min_length: 15, max_length: 15

  account = Account.first(:username => params[:username])

  if account.nil?
    halt 400, {:message => 'Account matching such session was not found'}.to_json
  end

  if account.session.nil?
    halt 400, {:message => 'Account not using session'}.to_json
  end

  account.update(:session => nil)
  {:success => 'Successfully logout'}.to_json
end

post '/lookup' do
  found = Account.all(:fields => [:id, :username], :username.like => '%' + params[:username] + '%')

  if found.empty?
    {:message => 'Accounts matching such username was not found'}.to_json
  else
    found.map(&:username).to_json
  end
end

post '/changepassword' do
  param :old_password, String, required: true, min_length: 5, max_length: 25
  param :new_password, String, required: true, min_length: 5, max_length: 25

  account = Account.first(:username => params[:username])

  if account.nil?
    halt 400, {:message => 'Account matching such username was not found'}.to_json
  end

  unless account.password == params[:old_password]
    halt 401, {:message => 'Parameter is invalid', :errors => {:old_password => 'Parameter is invalid'}}.to_json
  end

  account.update(:password => BCrypt::Password.create(params[:new_password]))
  {:success => 'Successfully changed password'}.to_json
end
