
module WRSRSkinner
  class Logo

    BaseDir = __dir__ + "/../../data-raw/logos/"

    def self.valid_logo_names
      Dir[BaseDir + "/*.png"].map {|f| File.basename(f, ".png")}
    end

    include Magick

    attr_reader :logo_name

    def initialize(logo_name)
      raise "Invalid logo name #{logo_name}" unless self.class.valid_logo_names.include? logo_name
      @logo_name = logo_name
    end

    def logo_path
      BaseDir + "/" + self.logo_name + ".png"
    end

    def logo_mask
      return @logo_mask_memo if @logo_mask_memo

      ret = Image.read(self.logo_path).first
      ret.colorspace = RGBColorspace
      ret.alpha(ActivateAlphaChannel)

      if ret.pixel_color(1,1).red > (0.8*Magick::QuantumRange) then
       ret.fuzz = 50000
        ret = ret.transparent("#FDFAE9")
        ret = ret.transparent("#FFFFFF")
      else
        ret.fuzz = 28000
        ret = ret.transparent("#0778A9")
        ret = ret.transparent("#0D73A8")
      end


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

