require "open-uri"

module EmailCrawler
  class EmailScanner
    EMAIL_REGEXP = /\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/i
    SLEEP_TIME = 0.5
    UTF_8 = "UTF-8".freeze

    def initialize(url)
      @url = url
      @logger = ::Logger.new(STDOUT).tap do |logger|
        logger.level = ENV["DEBUG"] ? Logger::INFO : Logger::ERROR
      end
    end

    def scan(links)
      emails_by_link = {}

      links.each do |link|
        @logger.info "searching for emails on '#{link}'.."
        retried = false

        html = begin
          open(link).read
        rescue OpenURI::HTTPError => err
          @logger.warn(err)
          nil
        rescue => err
          if err.message =~ /redirection forbidden/
            link = err.message.split(" ").last
            retry
          end
        end
        next unless html

        begin
          emails = html.scan(EMAIL_REGEXP)
        rescue ArgumentError => err
          if retried
            emails = []
          else
            @logger.warn err.inspect
            html.encode!(UTF_8, UTF_8, invalid: :replace, undef: :replace, replace: "")
            retried = true
            retry
          end
        end
        emails_by_link[link] = Set.new(emails) unless emails.empty?
        sleep(SLEEP_TIME)
      end

      emails_by_link
    end
  end
end
