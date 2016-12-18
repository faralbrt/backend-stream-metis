class Scraper
  def initialize
    @agent = Mechanize.new {|agent| agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.87 Safari/537.36"}
  end

  def gather_asins(uri)
    response = @agent.get(uri)
    response = response.body.delete("[]\"")
    response = response.split(",").map {|a| a.strip}
    binding.pry
  end
end
