begin
  require 'yaml'
  require 'json'
  require 'open-uri'

  namespace :oembed do
    desc "Update the embedly_urls.yml file using the services api."
    task :update_embedly do
      # Details at http://api.embed.ly/docs/service
      json_uri = URI.parse("http://api.embed.ly/1/services")
      yaml_path = File.join(File.dirname(__FILE__), "../oembed/providers/embedly_urls.yml")
    
      services = JSON.parse(json_uri.read)
    
      url_regexps = []
      services.each do |service|
        url_regexps += service['regex'].map{|r| r.strip }
      end
      url_regexps.sort!
    
      YAML.dump(url_regexps, File.open(yaml_path, 'w'))
    end
  
    # Note: At the moment the list of enpoints in the oohembed-provided JSON file
    # do NOT match the full listing on their website. Until we sort that out, we'll
    # continue to use the manually entered list of oohembed URLs
    desc "Update the list of URLs supported by oohembed via their API"
    task :update_oohembed do
      # Details in the Q & A section of http://oohembed.com/
      json_uri = URI.parse("http://oohembed.com/static/endpoints.json")
      yaml_path = File.join(File.dirname(__FILE__), "../oembed/providers/oohembed_urls.yml")
    
      services = JSON.parse(json_uri.read)
    
      url_regexps = []
      services.each do |service|
        url_regexps << service['url']
      end
      url_regexps.sort!
    
      YAML.dump(url_regexps, File.open(yaml_path, 'w'))
    end
  end  
rescue LoadError
  puts "The oembed rake tasks require JSON. Install it with: gem install json"
end