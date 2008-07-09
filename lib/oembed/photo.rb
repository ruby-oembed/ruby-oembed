module OEmbed
  class Photo < OEmbed::Response
    def html
      "<img src='" + self.url + "' />"
    end
  end
end