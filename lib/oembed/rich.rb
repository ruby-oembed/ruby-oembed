module OEmbed
  class Rich < Response
    def html_code
      self.html
    end
  end
end