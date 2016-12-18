class Scraper
  attr_accessor :agent, :asins_to_scrape, :results
  def initialize
    @agent = Mechanize.new {|agent| agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.87 Safari/537.36"}
    @results = []
  end

  def gather_asins(uri)
    response = @agent.get(uri)
    response = response.body.delete("[]\"")
    @asins_to_scrape = response.split(",").map {|a| a.strip}
  end

  def scrape_all_asins
    @asins_to_scrape.each do |asin|
      scrape_asin(asin)
      sleep(rand(3..6))
    end
  end

  private

  def scrape_asin(asin)
    website = 'https://www.amazon.com/gp/offer-listing/' + asin + '/ref=olp_f_primeEligible?ie=UTF8&f_new=true&f_primeEligible=true'
    page = @agent.get(website)
    @results << {"#{asin}" => parse_page(page)}
  end

  def parse_page(page)
    title = page.at_css("h1.a-size-large.a-spacing-none").text.strip || "n/a"
    price = page.at_css("span.a-size-large.a-color-price.olpOfferPrice.a-text-bold").text.strip || "n/a"
    return [title, price]
  end
end
