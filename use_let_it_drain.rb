require 'bundler'
Bundler.require(:default, :development)

puts url = ENV['LET_IT_DRAIN_URL']
log = Logglier.new(url)

3.times { log.warn "so WOW much LOG!" }
