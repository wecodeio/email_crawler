module EmailCrawler
  class EmailScanner
    EMAIL_REGEXP = /\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/i
    UTF_8 = "UTF-8".freeze

    include MechanizeHelper

    def initialize(logger = Logger.new("/dev/null"))
      @logger = logger
    end

    def scan(links)
      links.each_with_object({}) do |link, h|
        @logger.info "searching for emails on '#{link}'.."
        retried = false

        begin
          html = get(link).body
        rescue => err
          @logger.warn err.inspect
          nil
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

        h[link] = Set.new(emails) unless emails.empty?
      end
    end
  end
end
