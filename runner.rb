require_relative 'scraper'
require_relative '../../config/environment'

sleep(1)
puts "hello"
host = 'http://127.0.0.1:9393'
scraper = Scraper.new
scraper.gather_asins(host + '/asins')
scraper.scrape_all_asins(host + '/asinlogs')

# bundle exec ruby ./app/models/runner.rb
