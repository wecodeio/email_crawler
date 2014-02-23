module EmailCrawler
  class PageLinks
    MAX_LINKS  = 100
    SLEEP_TIME = 0.5

    include MechanizeHelper

    def initialize(url)
      @url = url
      uri = URI(url)
      scheme_and_host = if uri.host
                          "#{uri.scheme}://#{uri.host}"
                        else
                          url[%r(\A(https?://([^/]+))), 1]
                        end
      @domain = Regexp.new("#{scheme_and_host}/", true)
      @logger = ::Logger.new(STDOUT).tap do |logger|
        logger.level = ENV["DEBUG"] ? Logger::INFO : Logger::ERROR
      end
    end

    def self.for(url, max_links = MAX_LINKS)
      new(url).fetch_links(max_links)
    end

    def fetch_links(max_links = MAX_LINKS)
      queue, links = Set.new([@url]), Set.new([@url])

      until queue.empty?
        current_link = queue.first
        @logger.info "current_link: #{current_link}"
        page = get(current_link)

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
