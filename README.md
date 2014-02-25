# EmailCrawler

Email crawler: crawls the top ten Google search results looking for email addresses and exports them to CSV.

## Installation

    $ gem install email_crawler
    $ cp .env.example .env
    # set your Digital Ocean credentials (@see lib/email_crawler/proxy.rb for more details)

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

5. Redirect output to a file

```bash
email-crawler -q "berlin walks" -g google.de -m 250 > ~/Desktop/belin-walks-emails.csv
```

## Contributing

1. Fork it ( http://github.com/cristianrasch/email_crawler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
