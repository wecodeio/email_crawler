require_relative "../../spec_helper"

require File.expand_path("lib/email_crawler")

module EmailCrawler
  describe PageLinks do
    let(:max_links) { 25 }

    it "returns the first N internal links" do
      PageLinks.for("http://www.visitberlin.de/en", max_links: max_links).length.must_equal max_links
    end
  end
end
