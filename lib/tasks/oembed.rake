begin
  require 'yaml'
  require 'json'
  require 'open-uri'

  namespace :oembed do
    desc 'Update the embedly_urls.yml file using the services api.'
    task :update_embedly do
      # Details at http://api.embed.ly/docs/service
      json_uri = URI.parse('http://api.embed.ly/1/services')
      yaml_path = File.join(
        File.dirname(__FILE__),
        '../oembed/providers/aggregator/embedly_urls.yml'
      )

      services = JSON.parse(json_uri.read)

      url_regexps = []
      services.each do |service|
        url_regexps += service['regex'].map(&:strip)
      end
      url_regexps.sort!

      YAML.dump(url_regexps, File.open(yaml_path, 'w'))
    end
  end
rescue LoadError
  puts 'The oembed rake tasks require JSON. Install it with: gem install json'
end
