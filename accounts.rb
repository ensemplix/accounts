require 'sinatra/param'
require 'data_mapper'
require 'sinatra'
require 'json'

$TOKEN = ""

DataMapper.setup(:default, 'mysql://user:password@localhost/accounts')

class Account
  include DataMapper::Resource

  property :id, Serial
  property :username, String, :length => 15, :unique_index => true 
  property :email, String, :length => 255
  property :password, BCryptHash
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

before /^(?!\/(lookup))/ do
  param :password, String, required: true, min_length: 5, max_length: 25
end

post '/register' do

end

post '/login' do

end

post '/lookup' do
  
end

post '/changepassword' do

end
