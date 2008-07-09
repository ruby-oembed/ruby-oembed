module OEmbed
  class Photo < OEmbed::Response
    def html_code
      "<img src='" + self.url + "' />"
    end
  end
end