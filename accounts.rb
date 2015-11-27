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

  if params[:token].nil?
    halt 401, {:error => 'Please provide token'}.to_json
  end

  unless params[:token].eql? $TOKEN
    halt 401, {:error => 'Incorrect token'}.to_json
  end
end

post '/register' do

end

post '/login' do

end

post '/lookup' do
  
end

post '/changepassword' do

end
