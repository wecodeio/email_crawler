require "open-uri"
require "json"

module EmailCrawler
  DO_CLIENT_ID = "AfwKCiugYlqOkLnYQdWxZ".freeze
  DO_API_KEY = "4oZlRXSoMdGnzziaPPq5aoU8uTWv4atgL9fsy8jmo".freeze

  class Proxy
    class << self
      def random
        all.sample
      end

    private

      def all
        @all ||= begin
          json = JSON.parse(open("https://api.digitalocean.com/droplets/?client_id=#{DO_CLIENT_ID}&api_key=#{DO_API_KEY}").read)
          json["droplets"].
            select{ |droplet| droplet["name"] =~ /proxy\d+/ }.
            map { |droplet| droplet["ip_address"] }
        end
      end
    end
  end
end


