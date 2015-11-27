require 'sinatra'
require 'json'

$TOKEN = ""

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
