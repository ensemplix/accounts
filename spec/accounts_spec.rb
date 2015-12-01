require File.expand_path '../spec_helper.rb', __FILE__

describe 'Accounts' do
  include Rack::Test::Methods

  context 'Signature' do
    it 'required' do
      post '/lookup'

      expect(last_response.body).to include('Header is required')
    end

    it 'invalid' do
      header 'API-SIGNATURE', 'Empty token'
      post '/lookup'

      expect(last_response.body).to include('Header is invalid')
    end

    it 'match' do
      header 'API-SIGNATURE', signature(:username => 'koala')
      post '/lookup', :username => 'koala'

      expect(last_response.body).not_to include('Header is invalid')
    end
  end

  context 'Register' do
    account = {
        :username => 'koala',
        :password => 'strongpassword',
        :email => 'koala@ensemplix.ru',
        :ip => '127.0.0.1'
    }

    it 'created' do
      header 'API-SIGNATURE', signature(account)
      post '/register', account

      expect(last_response.body).to include('Successfully created new account')
    end

    it 'exists' do
      header 'API-SIGNATURE', signature(account)
      post '/register', account

      expect(last_response.body).to include('Account already exists')
    end
  end

  context 'Lookup' do
    it 'found' do
      header 'API-SIGNATURE', signature(:username => 'koal')
      post '/lookup', :username => 'koal'

      expect(last_response.body).to include('koala')
    end

    it 'not found' do
      header 'API-SIGNATURE', signature(:username => 'ensiriuswOw')
      post '/lookup', :username => 'ensiriuswOw'

      expect(last_response.body).to include('Accounts matching such username was not found')
    end
  end

  context 'Change password' do
    change = {
        :username => 'koala',
        :old_password => 'strongpassword',
        :new_password => 'strongpassword2'
    }

    it 'updated' do
      header 'API-SIGNATURE', signature(change)
      post '/changepassword', change

      expect(last_response.body).to include('Successfully changed password')
    end

    it 'not updated' do
      header 'API-SIGNATURE', signature(change)
      post '/changepassword', change

      expect(last_response.body).to include('Parameter is invalid')
    end
  end

  def signature(params)
    query = params.map{|k,v| "#{k}=#{v}"}.join('&').gsub('@', '%40')
    digest = OpenSSL::Digest.new('SHA1')
    token = ENV['SECRET_TOKEN']

    return OpenSSL::HMAC.hexdigest(digest, token, query)
  end

end
