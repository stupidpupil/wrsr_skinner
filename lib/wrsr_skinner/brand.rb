
module WRSRSkinner
  class Brand

    include Magick

    attr_reader :colors, :logo_name, :logo, :override_logo_flip_x

    def initialize(colors={}, logo_name=nil)
      @colors = colors
      @logo_name = logo_name
      @logo = Logo.new(logo_name)
    end

    def logo_image
      return nil if self.logo_name.nil?

      logo_color = self.colors[:logo]

      self.logo.logo_with_color(logo_color)
    end

  end
end