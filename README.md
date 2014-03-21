# EmailCrawler

Email crawler: crawls the top ten Google search results looking for email addresses and exports them to CSV.

## Installation

    $ gem install email_crawler
    $ cp .env.example .env
    # set your Digital Ocean credentials (@see lib/email_crawler/proxy.rb for more details)

## Usage

* Ask for help

```bash
email-crawler --help
```

* Simplest Google search

```bash
email-crawler --query "berlin walks"
```

* Select which Google website to use (defaults to google.com.br)

```bash
email-crawler --query "berlin walks" --google-website google.de
```

* Specify how many search results URLs to collect (defaults to 100)

```bash
email-crawler --query "berlin walks" --max-results 250
```

* Specify how many internal links are to be scanned for email addresses (defaults to 100)

```bash
email-crawler --query "berlin walks" --max-links 250
```

* Specify how many threads to use when searching for links and email addresses (defaults to 50)

```bash
email-crawler --query "berlin walks" --concurrency 25
```

* Redirect output to a file

```bash
email-crawler --query "berlin walks" > ~/Desktop/belin-walks-emails.csv
```

## Contributing

1. Fork it ( http://github.com/wecodeio/email_crawler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
