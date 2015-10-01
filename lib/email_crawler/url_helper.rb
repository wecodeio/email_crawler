require "English"

module URLHelper
  DOMAIN_REGEXP = %r(https://([^/]+))i
  WWW_REGEXP = /\Awww[.]/i

  def extract_domain_from(url, www = false)
    uri = begin
            URI(url)
          rescue URI::InvalidURIError
            return
          end
    host = uri.host || url[DOMAIN_REGEXP, 1].to_s

    if www || host !~ WWW_REGEXP
      host.downcase
    else
      $POSTMATCH.downcase
    end
  end
end
