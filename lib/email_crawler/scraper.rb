require_relative "proxy"

module EmailCrawler
  class Scraper
    MAX_URLS = 10

    include MechanizeHelper

    def initialize(google_website)
      @google_website = "https://www.#{google_website}/"
    end

    def top_ten_urls_for(q)
      search_page = agent.get(@google_website)
      search_form = search_page.form_with(action: "/search")
      search_form.field_with(name: "q").value = q
      search_results_page = agent.submit(search_form)
      search_results_page.search("#search ol li h3.r a").
        map { |a| a["href"].downcase }.
        reject { |url| url =~ %r(\A/search[?]q=) }.
        first(MAX_URLS)
    end

  private

    def agent
      @agent ||= new_agent { |agent| agent.set_proxy(Proxy.random, "8888") }
      # @agent ||= new_agent
    end
  end
end
