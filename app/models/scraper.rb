class Scraper
  attr_accessor :agent, :asins_to_scrape, :results
  def initialize
    @agent = Mechanize.new {|agent| agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.87 Safari/537.36"}
  end

  def gather_asins(url)
    response = @agent.get(url)
    response = response.body.delete("[]\"")
    @asins_to_scrape = response.split(",").map {|a| a.strip}
  end

  def scrape_all_asins(post_to_uri)
    @asins_to_scrape.each do |asin|
      results = scrape_asin(asin)
      post_to_stream(post_to_uri, results[:asin], results[:title], results[:price])
      sleep(rand(3..6))
    end
  end

  private

  def scrape_asin(asin)
    website = 'https://www.amazon.com/gp/offer-listing/' + asin + '/ref=olp_f_primeEligible?ie=UTF8&f_new=true&f_primeEligible=true'
    page = @agent.get(website)
    page = parse_page(page)
    {asin: asin, title: page[0], price: page[1]}
  end

  def parse_page(page)
    title = page.at_css("h1.a-size-large.a-spacing-none") || "n/a"
    price = page.at_css("span.a-size-large.a-color-price.olpOfferPrice.a-text-bold") || "n/a"
    title = title.text.strip unless title == 'n/a'
    price = price.text.strip unless price == 'n/a'
    return [title, price]
  end

  def post_to_stream(uri, asin, title, price)
    uri = URI(uri)
    Net::HTTP.post_form(uri, 'asin' => asin, 'title' => title, 'price' => price)
  end
end

# uri = URI('http://127.0.0.1:9393/asinlogs')
# res = Net::HTTP.post_form(uri, 'asin' => "B003WCR7O0", 'title' => "Wet Line Xtreme Gel Clear, 8.8 oz", 'price' => "$4.05")
