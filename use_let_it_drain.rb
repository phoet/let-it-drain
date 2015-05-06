require 'bundler'
Bundler.require
require_relative 'mongo'

puts ENV['LET_IT_DRAIN_URL']

log = Logglier.new(ENV['LET_IT_DRAIN_URL'])
# log = Logglier.new('https://logs-01.loggly.com/inputs/your-customer-token')
100.times { log.warn boom: :box, bar: :soap }
