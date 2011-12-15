require 'data_mapper'
require 'sinatra'
require 'json'
require 'haml'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class Ranking
  include DataMapper::Resource
  property :points, Integer
  property :nick,   String
  property :id,     Serial
end

DataMapper.finalize.auto_upgrade!

AUTH_USER = ENV['AUTH_USER']
AUTH_PASS = ENV['AUTH_PASS']

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [AUTH_USER,AUTH_PASS]
  end
end

# Application

get '/' do
  haml :index
end

get '/scoreboard' do
  Ranking.all.to_json
end

post '/reset' do
  protected!
  Ranking.all.destroy
end

post '/:nick' do
  protected!
  r = Ranking.first(:nick => params[:nick]) || Ranking.create(:nick => params[:nick])
  r.update(:points => params[:points]) && r.to_json
end
