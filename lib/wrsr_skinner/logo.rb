
module WRSRSkinner
  class Logo

    include Magick

    attr_reader :logo_name

    BaseDir = __dir__ + "/../../data-raw/logos/"

    def initialize(logo_name)
      raise "Invalid logo name" unless logo_name =~ /\A[a-z]+\Z/
      @logo_name = logo_name
      raise "Logo doesn't exist #{logo_path}" unless File.file? logo_path
    end

    def logo_path
      BaseDir + "/" + self.logo_name + ".png"
    end

    def logo_mask
      return @logo_mask_memo if @logo_mask_memo

      ret = Image.read(self.logo_path).first
      ret.colorspace = RGBColorspace
      ret.alpha(ActivateAlphaChannel)

      ret.fuzz = 50000
      ret = ret.transparent("#FDFAE9")
      ret = ret.transparent("#FFFFFF")

      #ret = ret.channel(RedChannel|GreenChannel|BlueChannel).negate().composite(ret, CenterGravity, CopyAlphaCompositeOp)
      ret.alpha(ActivateAlphaChannel)

      @logo_mask_memo = ret.freeze

      return(ret)
    end

    def logo_with_color(logo_color)
      mask = self.logo_mask
      overlay = Image.new(mask.columns, mask.rows) { |img| img.background_color = logo_color}
      overlay.alpha(ActivateAlphaChannel)
      overlay.composite(mask, CenterGravity, DstInCompositeOp)
    end

  end
end

