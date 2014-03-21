require "mechanize"

module EmailCrawler
  module MechanizeHelper
    def new_agent
      Thread.current[:agent] ||= Mechanize.new do |agent|
        agent.user_agent_alias = "Mac Safari"
        agent.open_timeout = agent.read_timeout = 30
        agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
        agent.history.max_size = 1
        yield(agent) if block_given?
      end
    end

    def get(url)
      retried = false

      begin
        page = agent.get(url)
        page if page.is_a?(Mechanize::Page)
      rescue Mechanize::Error;
      rescue SocketError, Net::OpenTimeout
        unless retried
          retried = true
          retry
        end
      end
    end
  end
end
