# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_crawler/version'

Gem::Specification.new do |spec|
  spec.name          = "email_crawler"
  spec.version       = EmailCrawler::VERSION
  spec.authors       = ["Cristian Rasch"]
  spec.email         = ["cristianrasch@fastmail.fm"]
  spec.summary       = %q{Email crawler: crawls the top ten Google search results looking for email addresses and exports them to CSV.}
  spec.homepage      = "https://github.com/cristianrasch/email_crawler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mechanize"
  spec.add_runtime_dependency "dotenv"
  spec.add_runtime_dependency "thread_safe"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.2.3"
end
