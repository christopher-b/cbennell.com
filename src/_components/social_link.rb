class SocialLink < Bridgetown::Component
  def initialize(url, title, svg)
    @url = url
    @title = title
    @svg = svg
  end
end

