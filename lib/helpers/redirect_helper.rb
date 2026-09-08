# helpers/redirect_helper.rb
module RedirectHelper
  # Paths that belong to the host and have no language: the two files every
  # crawler asks for at the root, and the well-known namespace.
  HOST_FILES = ['/robots.txt', '/sitemap.xml'].freeze

  def host_file?(path)
    HOST_FILES.include?(path) || path.start_with?('/.well-known/')
  end

  def unify_domains(host, path)
    # Domains to redirect, including kleer.la per TODO
    redirect_domains = ['kleer.us', 'kleer.es', 'www.kleer.us', 'www.kleer.es', 'kleer.la']

    # Determine locale based on host, replicating existing logic
    locale = if path.start_with?('/en')
               'en'
             elsif path.start_with?('/es')
               'es'
             elsif host.include?('kleer.us')
               'en'
             else
               'es'
             end

    if redirect_domains.include?(host)
      # Validate locale, though host-based logic ensures it's en/es
      locale = locale.to_s.match?(/^(en|es)$/) ? locale : 'es'
      # Add language prefix unless path starts with /en or /es, or the path is
      # a file of the host rather than of a page. robots.txt lives at the root
      # by specification and governs everything crawled on that host: sending
      # kleer.la/robots.txt to /es/robots.txt resolves, but leaves the file that
      # decides what gets crawled depending on the language rewrite.
      lang = "/#{locale}" unless ['/en', '/es'].include?(path[0, 3]) || host_file?(path)
      # Construct target URL
      target_url = "https://www.kleer.la#{lang}#{path}"
      # Return nil for target_url if already on correct host and path
      return [nil, locale] if host == 'www.kleer.la' && path.start_with?("/#{locale}")

      [target_url, locale]
    else
      [nil, locale] # No redirect, but return locale for consistency
    end
  end
end
