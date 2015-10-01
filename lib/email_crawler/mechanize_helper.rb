require "mechanize"

module EmailCrawler
  module MechanizeHelper
    READ_TIMEOUT = 15

    def new_agent
      Thread.current[:agent] ||= Mechanize.new do |agent|
        agent.user_agent_alias = "Windows Mozilla"
        agent.open_timeout = agent.read_timeout = READ_TIMEOUT
        agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
        agent.history.max_size = 1
        yield(agent) if block_given?
      end
    end

    def get(url)
      retried = false

      begin
        page = begin
                 Timeout::timeout(READ_TIMEOUT) do
                   agent.get(url)
                 end
               rescue Timeout::Error
                 unless retried
                   retried = true
                   retry
                 end
               end
        page if page.is_a?(Mechanize::Page)
      rescue Mechanize::Error;
      rescue SocketError
        unless retried
          retried = true
          retry
        end
      end
    end

    private

    def agent
      @agent ||= new_agent
    end
  end
end
