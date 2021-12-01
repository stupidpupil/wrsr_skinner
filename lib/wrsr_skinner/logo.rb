
module WRSRSkinner
  class Logo

    include Magick

    attr_reader :logo_name

    def initialize(logo_name)
      @logo_name = logo_name
    end

    def logo_path
      "data-raw/logos/#{self.logo_name}.png"
    end

    def logo_mask
      return @logo_mask_memo if @logo_mask_memo

      ret = Image.read(self.logo_path).first
      ret.colorspace = RGBColorspace
      ret.alpha(ActivateAlphaChannel)

      ret.fuzz = 50000
      ret = ret.transparent("#FDFAE9")
      ret = ret.transparent("#FFFFFF")

      ret = ret.channel(RedChannel|GreenChannel|BlueChannel).negate().composite(ret, CenterGravity, CopyAlphaCompositeOp)
      ret.alpha(ActivateAlphaChannel)

      @logo_mask_memo = ret.freeze

      return(ret)
    end

    def logo_with_color(logo_color)
      ret = self.logo_mask.copy

      overlay = Image.new(ret.columns, ret.rows) { |img| img.background_color = logo_color; }

      ret.composite(overlay, CenterGravity, MultiplyCompositeOp).composite(ret, CenterGravity, CopyAlphaCompositeOp)
    end

  end
end

