require_relative "../../spec_helper"

require File.expand_path("lib/email_crawler")

module EmailCrawler
  describe EmailScanner do
    subject { EmailScanner.new }

    let(:link) { "https://www.mrosupply.com/page/plain/contact-us/" }

    it "scans links for email addresses" do
      emails_by_link = subject.scan([link])
      emails_by_link[link].wont_be_empty
    end
  end
end
