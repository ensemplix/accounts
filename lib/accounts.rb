require 'http'
require 'json'

module Accounts

  class AccountsParseError < StandardError; end

  class Client
    def initialize(token, url)
      @token, @url  = token, url
    end

    def register(username, password, email, ip)
      request('register', {
          :username => username,
          :password => password,
          :email => email,
          :ip => ip
      })
    end

    def login_password(username, password, remember = false)
      request('login', {
          :username => username,
          :password => password,
          :remember => remember,
      })
    end

    def login_session(username, session)
      request('login', {
          :username => username,
          :session => session,
      })
    end

    def logout(session)
      request('logout', {
          :session => session
      })
    end

    def lookup(username)
      request('lookup', {
          :username => username
      })
    end

    def changepassword(username, old_password, new_password)
      request('changepassword', {
          :username => username,
          :old_password => old_password,
          :new_password => new_password
      })
    end

    private

    def request(path, params)
      body = HTTP.headers('API-SIGNATURE' => signature(params)).post(@url + '/' + path, :form => params).to_s
      result = JSON.parse(body)

      if result.has_key? :message
        raise AccountsParseError(result)
      end

      return result
    end

    def signature(params)
      query = params.map{|k,v| "#{k}=#{v}"}.join('&').gsub('@', '%40')
      digest = OpenSSL::Digest.new('SHA1')

      OpenSSL::HMAC.hexdigest(digest, @token, query)
    end
  end

end
