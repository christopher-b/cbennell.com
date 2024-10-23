# This is a placeholder/example; these methods are not in use
module SiteResourceExtension
  def self.summary(resource)
    resource.summary
  end

  module LiquidResource
    def custom_summary
      SiteResourceExtension.summary(self)
    end
  end

  module RubyResource
    def custom_summary(arg = nil)
      SiteResourceExtension.summary(self)
    end
  end
end

Bridgetown::Resource.register_extension SiteResourceExtension
