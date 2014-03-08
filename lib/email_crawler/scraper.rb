require_relative "proxy"

module EmailCrawler
  class Scraper
    MAX_RESULTS = 100

    include MechanizeHelper

    def initialize(google_website, max_results = MAX_RESULTS)
      @google_website = "https://www.#{google_website}/"
      @max_results = max_results
    end

    def search_result_urls_for(q)
      search_page = agent.get(@google_website)
      search_form = search_page.form_with(action: "/search")
      search_form.field_with(name: "q").value = q
      search_results_page = agent.submit(search_form)
      urls = search_results_on(search_results_page)

      page = 1
      while urls.size < @max_results
        next_page_link = search_results_page.link_with(href: /start=#{page*10}/)
        return urls unless next_page_link

        next_search_results_page = next_page_link.click
        urls.concat(search_results_on(next_search_results_page)).uniq!
        page += 1
      end

      urls.first(@max_results)
    end

  private

    def search_results_on(page)
      page.search("#search ol li h3.r a").
        map { |a| a["href"].downcase }.
        reject { |url| url =~ %r(\A/search[?]q=) }
    end

    def agent
      @agent ||= new_agent
      # @agent ||= new_agent { |agent| agent.set_proxy(Proxy.random, "8888") }
    end
  end
end
