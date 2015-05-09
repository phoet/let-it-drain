STDOUT.sync = true

require 'bundler'
Bundler.require
require_relative 'mongo'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  before do
    show_request
  end

  use Rack::Session::Cookie, secret: ENV['SSO_SALT']

  set :sockets, {}

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
      puts "request: #{request.request_method} #{request.path} #{params.inspect}"
      puts "request body: #{request_body}" unless request_body.empty?
    end

    def request_body
      @request_body ||= request.body.read
    end

    def json_body
      @json_body ||= JSON.parse(request_body)
    end

    def get_resource
      Resource.find(params[:id]) or halt 404, 'resource not found'
    end
  end

  # websocket
  get '/logs' do
    request.websocket do |ws|
      ws.onopen do
        @resource = session[:resource]
        settings.sockets[@resource.id.to_s] = ws
      end
      ws.onclose do
        @resource = session[:resource]
        warn("websocket #{@resource.id.to_s} closed")
        settings.sockets.delete(@resource.id.to_s)
      end
    end
  end

  # drain endpoint
  post '/drain/:id' do
    LogEntry.create! resource_id: params[:id], message: request_body
    if socket = settings.sockets[params[:id]]
      socket.send(request_body)
    end
  end

  # sso landing page
  get "/" do
    halt 403, 'not logged in' unless session[:heroku_sso]
    response.set_cookie('heroku-nav-data', value: session[:heroku_sso])
    @resource = session[:resource]
    @email    = session[:email]
    @logs     = LogEntry.where(resource_id: @resource.id.to_s)
    haml :index
  end

  # sso sign in
  get "/heroku/resources/:id" do
    sso
  end

  post '/sso/login' do
    sso
  end

  # provision
  post '/heroku/resources' do
    protected!

    resource = Resource.create!(
      :heroku_id => json_body['heroku_id'],
      :plan => json_body.fetch('plan', 'test'),
      :region => json_body['region'],
      :callback_url => json_body['callback_url'],
      :options => json_body['options']
    )
    status 201
    log_drain_url = "#{request.scheme}://#{request.host}:#{request.port}/drain/#{resource.id.to_s}"
    response = {
      id: resource.id.to_s,
      config: {"LET_IT_DRAIN_URL" => log_drain_url},
      log_drain_url: log_drain_url,
      message: "let-it-drain here: #{log_drain_url}",
    }

    body(response.to_json)
  end

  # deprovision
  delete '/heroku/resources/:id' do
    protected!
    get_resource.destroy
    "ok"
  end

  # plan change
  put '/heroku/resources/:id' do
    protected!
    resource = get_resource
    resource.update_attributes! plan: json_body['plan']
    resource.save
    {}.to_json
  end

  private

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
end
