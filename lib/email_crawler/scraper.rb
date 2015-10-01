require "set"
require_relative "mechanize_helper"
require_relative "url_helper"

module EmailCrawler
  class Scraper
    MAX_RESULTS = 100

    include MechanizeHelper
    include URLHelper

    def initialize(google_website, max_results: MAX_RESULTS, blacklisted_domains: [])
      @search_url = "https://www.#{google_website}/search?q="
      @max_results = max_results
      @blacklisted_domains = blacklisted_domains.map { |domain| /#{domain}\z/ }
    end

    def search_result_urls_for(q)
      search_results_page = agent.get(@search_url + CGI.escape(q))
      urls = Set.new(search_results_on(search_results_page))

      page = 1
      while urls.size < @max_results
        next_page_link = search_results_page.link_with(href: /start=#{page*10}/)
        break unless next_page_link

        next_search_results_page = next_page_link.click
        search_results_on(next_search_results_page).each do |url|
          urls << url
        end

        page += 1
      end

      urls.to_a.first(@max_results)
    end

    private

    def search_results_on(page)
      urls = page.search("#search ol li.g h3.r a").map do |a|
        href = a[:href]
        url = href =~ %r(/url\?q=) && $POSTMATCH

        if url
          url = url =~ /&sa=/ && $PREMATCH
          CGI.unescape(url) if url
        end
      end
      urls.compact!

      unless @blacklisted_domains.empty?
        urls.delete_if do |url|
          domain = extract_domain_from(url)
          @blacklisted_domains.any? { |blacklisted_domain| domain =~ blacklisted_domain }
        end
      end

      urls
    end

    def agent
      @agent ||= new_agent
    end
  end
end
