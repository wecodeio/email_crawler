require "thread"
require "logger"
require "csv"
require "set"

require_relative "email_crawler/version"
require_relative "email_crawler/mechanize_helper"
require_relative "email_crawler/scraper"
require_relative "email_crawler/page_links"
require_relative "email_crawler/email_scanner"

module EmailCrawler
  class Runner
    def initialize(google_website)
      @google_website = google_website

      log_file = File.join(ENV["HOME"], "email-crawler.log")
      file = File.open(log_file, File::WRONLY | File::APPEND | File::CREAT)
      @logger = ::Logger.new(file).tap do |logger|
        logger.level = ENV["DEBUG"] ? Logger::INFO : Logger::ERROR
      end
    end

    def run(q, max_results = Scraper::MAX_RESULTS, max_links = PageLinks::MAX_LINKS)
      urls = Scraper.new(@google_website, max_results).search_result_urls_for(q)
      urls.each { |url, links| @logger.info "#{url}" }

      threads = (1..urls.length).map do |i|
        Thread.new(i, urls[i-1]) do |i, url|
          @logger.info "[Thread ##{i}] grabbing page links for '#{url}'.."
          Thread.current[:url] = url
          Thread.current[:links] = PageLinks.for(url, max_links)
        end
      end

      threads.each(&:join)
      threads.each { |thread| @logger.info "#{thread[:url]} (#{thread[:links].length} links)" }
      links_by_url = Hash[threads.map { |thread| [thread[:url], thread[:links]] }]

      threads = (links_by_url).map.with_index do |arr, i|
        Thread.new(i+1, arr.first, arr.last) do |i, url, links|
          @logger.info "[Thread ##{i}] scanning for emails on page '#{url}' (#{links.length} links)"
          Thread.current[:url] = url
          Thread.current[:emails] = EmailScanner.new(url).scan(links)
        end
      end

      threads.each(&:join)

      read_emails = Set.new
      CSV.generate do |csv|
        csv << %w(Email Domain URL)
        csv << []

        threads.each do |thread|
          email_count = thread[:emails].inject(0) { |sum, arr| sum += arr.last.length }
          @logger.info "#{thread[:url]} (#{email_count} emails)"

          url = thread[:url]
          thread[:emails].each do |link, emails|
            emails.each do |email|
              csv << [email, url, link] if read_emails.add?(email)
            end
          end
        end
      end
    end
  end
end
