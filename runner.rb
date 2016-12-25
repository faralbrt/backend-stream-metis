require_relative 'scraper'

host = 'http://stream-metis.herokuapp.com'
scraper = Scraper.new
scraper.gather_asins(host + '/asins')
scraper.scrape_all_asins(host + '/asinlogs')
