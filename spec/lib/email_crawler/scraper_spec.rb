require_relative "../../spec_helper"

require File.expand_path("lib/email_crawler")

module EmailCrawler
  describe Scraper do
    subject { Scraper.new("google.de") }

    it "returns the top 10 URLs for a given search term/expression" do
      subject.top_ten_urls_for("berlin tours").length.must_equal 10
    end
  end
end
