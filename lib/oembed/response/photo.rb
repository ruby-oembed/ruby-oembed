module OEmbed
  class Response
    class Photo < self
      def html
        "<img src='" + self.url + "' />"
      end
    end
  end
end