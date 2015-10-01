module EmailCrawler
  class PageLinks
    MAX_LINKS  = 100
    SLEEP_TIME = 0.5
    MAX_RETRIES = 5

    include MechanizeHelper

    def initialize(url, logger = Logger.new("/dev/null"))
      @url = url
      uri = URI(url)
      scheme_and_host = if uri.host
                          "#{uri.scheme}://#{uri.host}"
                        else
                          url[%r(\A(https?://([^/]+))), 1]
                        end
      @domain = Regexp.new("#{scheme_and_host}/", true)
      @logger = logger
    end

    def self.for(url, max_links: MAX_LINKS, logger: Logger.new("/dev/null"))
      new(url, logger).fetch_links(max_links)
    end

    def fetch_links(max_links = MAX_LINKS)
      queue, links = Set.new([@url]), Set.new([@url])
      retries = 0

      until queue.empty?
        current_link = queue.first
        @logger.info "current_link: #{current_link}"

        begin
          page = get(current_link)
        rescue Net::HTTP::Persistent::Error => err
          @logger.warn err.inspect
          page = nil

          if retries < MAX_RETRIES
            retries += 1
            @logger.debug "Retry ##{retries}"
            agent.shutdown
            Thread.current[:agent] = nil
            sleep(SLEEP_TIME)
            retry
          else
            @logger.error "Giving up grabbing link for '#{@url}' after #{retries} retries"
            break
          end
        rescue URI::InvalidComponentError => err
          @logger.warn err.inspect
        else
          retries = 0
        end

        if page
          new_links = page.links_with(href: @domain).map(&:href)
          new_links.reject! { |link| links.include?(link) }
          @logger.debug "found: #{new_links.length} new link(s)"
          new_links.each { |link| queue << link }
          links << current_link

          if links.length == max_links
            break
          else
            sleep(SLEEP_TIME)
          end
        end

        queue.delete(current_link)
      end

      links.to_a
    end

    private

    def agent
      @agent ||= new_agent
    end
  end
end
