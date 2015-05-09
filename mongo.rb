Mongoid.load!('mongoid.yml')

class LogEntry
  include Mongoid::Document
  field :message, type: String
  field :resource_id, type: String
end

class Resource
  include Mongoid::Document
  field :heroku_id, type: String
  field :plan, type: String
  field :region, type: String
  field :callback_url, type: String
  field :log_input_url, type: String
  field :logplex_token, type: String
  field :options, type: String
  field :uuid, type: String
end
