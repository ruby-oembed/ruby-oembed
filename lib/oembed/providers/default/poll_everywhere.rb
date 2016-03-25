module OEmbed
  class Providers
    # Provider for polleverywhere.com
    PollEverywhere = OEmbed::Provider.new('http://www.polleverywhere.com/services/oembed/')
    PollEverywhere << 'http://www.polleverywhere.com/polls/*'
    PollEverywhere << 'http://www.polleverywhere.com/multiple_choice_polls/*'
    PollEverywhere << 'http://www.polleverywhere.com/free_text_polls/*'
    add_official_provider(PollEverywhere)
  end
end
