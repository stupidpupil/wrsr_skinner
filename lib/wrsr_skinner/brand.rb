
module WRSRSkinner
  class Brand

    include Magick

    attr_reader :colors, :logo

    def initialize(colors={})
      @colors = colors.map{|k,v| [k.to_s, v]}.to_h
      @logo = @colors['logo_name'].nil? ? nil : Logo.new(@colors['logo_name'])
    end

    def logo_image
      return nil if self.logo.nil?

      logo_color = self.colors['logo']

      self.logo.logo_with_color(logo_color)
    end

  end
end