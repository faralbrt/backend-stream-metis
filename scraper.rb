require 'mechanize'
require 'peddler'
require 'pry'

class Scraper
  attr_accessor :agent, :asins_to_scrape, :results
  def initialize
    @agent = Mechanize.new {|agent| agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.87 Safari/537.36"}
    @client = MWS::Products::Client.new
  end

  def gather_asins(url)
    response = @agent.get(url)
    response = response.body.delete("[]\"")
    @asins_to_scrape = response.split(",").map {|a| a.strip}
  end

  def scrape_all_asins(post_to_uri)
    prices = []
    products = []
    @asins_to_scrape.each_slice(10) do |asins|
      prices += @client.get_lowest_offer_listings_for_asin(asins).parse
      products += @client.get_matching_product(asins).parse
      sleep(6)
    end
    results = prices.zip(products)
    results = results.zip(@asins_to_scrape)
    results.each do |result|
      parse_and_post(post_to_uri, result)
    end
  end

  private

  def parse_and_post(uri, result)
    uri = URI(uri)
    Net::HTTP.post_form(uri, parse_result(result))
  end

  def parse_result(result)
    {'asin' => result.last, 'title' => parse_title(result), 'price' => parse_price(result)}
  end

  def parse_price(result)
    listings = result.first.first
    return "n/a" if listings["status"] == "ClientError"
    listings = listings["Product"]["LowestOfferListings"]["LowestOfferListing"]
    price = "n/a"
    listings.each do |listing|
      if listing["Qualifiers"]["FulfillmentChannel"] == "Amazon" && listing["Qualifiers"]["ItemCondition"] == "New"
        price = listing["Price"]["LandedPrice"]["Amount"]
        break
      end
    end
    return price
  end

  def parse_title(result)
    product = result.first.last
    return "n/a" if product["status"] == "ClientError"
    return product["Product"]["AttributeSets"]["ItemAttributes"]["Title"]
  end

end
