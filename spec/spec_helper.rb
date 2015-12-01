require 'rack/test'
require 'rspec'

ENV['DATABASE_URL'] = 'sqlite3://' + Dir.pwd + '/spec/test.db'
ENV['SECRET_TOKEN'] = 'Token'
ENV['RACK_ENV'] = 'test'

if File.exist?(Dir.pwd + '/spec/test.db')
  File.delete(Dir.pwd + '/spec/test.db')
end

require File.expand_path '../../accounts.rb', __FILE__

def app
  Sinatra::Application
end
