require "thread"
require "logger"
require "csv"
require "set"
require "thread_safe"

require_relative "email_crawler/version"
require_relative "email_crawler/mechanize_helper"
require_relative "email_crawler/scraper"
require_relative "email_crawler/page_links"
require_relative "email_crawler/email_scanner"

module EmailCrawler
  class Runner
    MAX_CONCURRENCY = 10

    attr_writer :max_results, :max_links, :max_concurrency

    def initialize(google_website)
      @google_website = google_website

      # @logger = ::Logger.new(STDOUT).tap do |logger|
      log_file = File.join(ENV["HOME"], "email-crawler.log")
      file = File.open(log_file, File::WRONLY | File::APPEND | File::CREAT)
      @logger = ::Logger.new(file).tap do |logger|
        logger.level = ENV["DEBUG"] ? Logger::INFO : Logger::ERROR
      end

      yield(self)

      @logger.info "max_results: #{@max_results}"
      @logger.info "max_links: #{@max_links}"
      @logger.info "max_concurrency: #{@max_concurrency}"
    end

    def run(q)
      urls = Scraper.new(@google_website, @max_results).search_result_urls_for(q)
      urls.each { |url| @logger.info "#{url}" }
      queue = Queue.new
      urls.each { |url| queue.push(url) }
      links_by_url = ThreadSafe::Array.new

      threads = (1..[urls.length, @max_concurrency].min).map do |i|
        Thread.new(i) do |i|
          url = begin
                  queue.pop(true)
                rescue ThreadError; end

          while url
            @logger.info "[Thread ##{i}] grabbing page links for '#{url}'.."
            links = PageLinks.for(url, @max_links)
            links_by_url << [url, links]

            url = begin
                    queue.pop(true)
                  rescue ThreadError; end
          end
        end
      end
      threads.each(&:join)
      @logger.debug "links_by_url: #{links_by_url.inspect}"

      links_by_url.each { |arr| queue.push(arr) }
      emails_by_url = ThreadSafe::Hash.new
      threads = (1..[links_by_url.length, MAX_CONCURRENCY].min).map do |i|
        Thread.new(i) do |i|
          arr = begin
                  queue.pop(true)
                rescue ThreadError; end

          while arr
            url, links = arr
            @logger.info "[Thread ##{i}] scanning for emails on page '#{url}' (#{links.length} links)"
            emails = EmailScanner.new(url).scan(links)
            emails_by_url[url] = emails

            arr = begin
                    queue.pop(true)
                  rescue ThreadError; end
          end
        end
      end
      threads.each(&:join)
      @logger.debug "emails_by_url: #{emails_by_url.inspect}"

      read_emails = Set.new
      CSV.generate do |csv|
        csv << %w(Email Domain URL)
        csv << []

        emails_by_url.each do |url, emails_by_link|
          email_count = emails_by_link.inject(0) { |sum, arr| sum += arr.last.length }
          @logger.info "#{url} (#{email_count} emails)"

          emails_by_link.each do |link, emails|
            emails.each do |email|
              csv << [email, url, link] if read_emails.add?(email)
            end
          end
        end
      end
    end
  end
end
