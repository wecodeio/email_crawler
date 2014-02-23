require "open-uri"
require "json"
require "dotenv"

module EmailCrawler
  class Proxy
    class << self
      def random
        all.sample
      end

    private

      def all
        @all ||= begin
          Dotenv.load

          json = JSON.parse(open("https://api.digitalocean.com/droplets/?client_id=#{ENV['DO_CLIENT_ID']}&api_key=#{ENV['DO_API_KEY']}").read)
          json["droplets"].
            select{ |droplet| droplet["name"] =~ /proxy\d+/ }.
            map { |droplet| droplet["ip_address"] }
        end
      end
    end
  end
end


