require_relative "../../spec_helper"

require File.expand_path("lib/email_crawler")

module EmailCrawler
  describe EmailScanner do
    subject { EmailScanner.new("google.com") }

    let(:link) { "http://www.kitaylaw.com/contact.php" }

    it "scans links for email addresses" do
      emails_by_link = subject.scan([link])
      emails_by_link[link].wont_be_empty
    end
  end
end
