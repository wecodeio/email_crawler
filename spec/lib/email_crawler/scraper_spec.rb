require_relative "../../spec_helper"

require File.expand_path("lib/email_crawler")

module EmailCrawler
  describe Scraper do
    let(:max_results) { 10 }

    subject { Scraper.new("google.de", max_results: max_results) }

    it "returns the top 10 URLs for a given search term/expression" do
      subject.search_result_urls_for("berlin tours").length.must_equal max_results
    end
  end
end
