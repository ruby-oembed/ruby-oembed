module OEmbed
  class Providers
    # Provider for noembed.com/, which "provides a single url
    # to get embeddable content from a large list of sites,
    # even sites without oEmbed support!"
    #
    # See https://noembed.com/#supported-sites for a list of supported sites.
    Noembed = OEmbed::Provider.new('http://noembed.com/embed')
    # Add all known URL regexps for Embedly.
    # To update this list run `bundle exec rake oembed:update_noembed`
    YAML.load_file(
      File.join(File.dirname(__FILE__), 'noembed_urls.yml')
    ).each do |url|
      Noembed << Regexp.new(url)
    end
    add_official_provider(Noembed, :aggregators)
  end
end
