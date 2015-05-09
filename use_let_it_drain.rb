require 'bundler'
Bundler.require(:default, :development)

puts ENV['LET_IT_DRAIN_URL']
log = Logglier.new(ENV['LET_IT_DRAIN_URL'])
log.warn boom: :box, bar: :soap
