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
  field :options, type: String
end
