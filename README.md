# EmailCrawler

Crawls the top ten Google results for any given search for email addresses.

## Installation

Add this line to your application's Gemfile:

    gem 'email_crawler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install email_crawler

## Usage

1. Ask for help

```bash
email-crawler --help
```

2. Simplest Google search

```bash
email-crawler -q "berlin walks"
```

3. Select which Google website to use (defaults to google.com.br)

```bash
email-crawler -q "berlin walks" -g google.de
```

4. Specify how many internal links are to be scanned for email addresses (defaults to 100)

```bash
email-crawler -q "berlin walks" -g google.de -m 250
```

## Contributing

1. Fork it ( http://github.com/cristianrasch/email_crawler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
