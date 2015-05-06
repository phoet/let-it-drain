require 'bundler'
Bundler.require


STDOUT.sync = true

require_relative 'mongo'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  use Rack::Session::Cookie, secret: ENV['SSO_SALT']

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
        @auth.credentials == [ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD']]
    end

    def show_request
      body = request.body.read
      unless body.empty?
        STDOUT.puts "request body:"
        STDOUT.puts(@json_body = JSON.parse(body))
      end
      unless params.empty?
        STDOUT.puts "params: #{params.inspect}"
      end
    end

    def json_body
      @json_body || (body = request.body.read && JSON.parse(body))
    end

    def get_resource
      Resource.find(params[:id]) or halt 404, 'resource not found'
    end
  end

  # sso landing page
  get "/" do
    halt 403, 'not logged in' unless session[:heroku_sso]
    #response.set_cookie('heroku-nav-data', value: session[:heroku_sso])
    @resource = session[:resource]
    @email    = session[:email]
    haml :index
  end

  def sso
    pre_token = params[:id] + ':' + ENV['SSO_SALT'] + ':' + params[:timestamp]
    token = Digest::SHA1.hexdigest(pre_token).to_s
    halt 403 if token != params[:token]
    halt 403 if params[:timestamp].to_i < (Time.now - 2*60).to_i

    halt 404 unless session[:resource]   = get_resource

    response.set_cookie('heroku-nav-data', value: params['nav-data'])
    session[:heroku_sso] = params['nav-data']
    session[:email]      = params[:email]

    redirect '/'
  end

  # sso sign in
  get "/heroku/resources/:id" do
    show_request
    sso
  end

  post '/sso/login' do
    puts params.inspect
    sso
  end

  post '/drain/:id' do
    puts params.inspect
    puts body = request.body.read
    LogEntry.create! resource_id: params[:id], message: body
  end

  # provision
  post '/heroku/resources' do
    show_request
    protected!

    resource = Resource.create!(
      :heroku_id => json_body['heroku_id'],
      :plan => json_body.fetch('plan', 'test'),
      :region => json_body['region'],
      :callback_url => json_body['callback_url'],
      :options => json_body['options']
    )
    status 201
    body({
           :id => resource.id.to_s,
           :config => {"LET_IT_DRAIN_URL" => "http://#{request.host}:#{request.port}/drain/#{resource.id.to_s}"},
    }.to_json)
  end

  # deprovision
  delete '/heroku/resources/:id' do
    show_request
    protected!
    get_resource.destroy
    "ok"
  end

  # plan change
  put '/heroku/resources/:id' do
    show_request
    protected!
    resource = get_resource
    resource.update_attributes! plan: json_body['plan']
    resource.save
    {}.to_json
  end
end
