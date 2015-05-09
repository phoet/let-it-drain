require 'bundler'
Bundler.require

log = Logglier.new(ENV['LET_IT_DRAIN_URL'])
log.warn boom: :box, bar: :soap
