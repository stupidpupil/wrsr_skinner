require 'RMagick'

class Brand

  include Magick

  attr_reader :colors, :logo_name

  #
  # Colors list
  # 0 - Base
  # 1 - Logo
  # 2 - Horizontal small stripe

  def initialize(colors=['transparent', 'black'], logo_name=nil)
    @colors = colors
    @logo_name = logo_name
  end

  def logo_path
    "data-raw/logos/#{self.logo_name}.png"
  end

  def logo_image
    return nil if self.logo_name.nil?

    logo_color = self.colors[1]

    ret = Image.read(self.logo_path).first
    ret.colorspace = RGBColorspace
    ret.alpha(ActivateAlphaChannel)

    ret.fuzz = 50000
    ret = ret.transparent("#FDFAE9")
    ret = ret.transparent("#FFFFFF")

    ret = ret.channel(RedChannel|GreenChannel|BlueChannel).negate().composite(ret, CenterGravity, CopyAlphaCompositeOp)
    ret.alpha(ActivateAlphaChannel)

    overlay = Image.new(ret.columns, ret.rows) {self.background_color = logo_color; }

    ret.composite(overlay, CenterGravity, MultiplyCompositeOp).composite(ret, CenterGravity, CopyAlphaCompositeOp)
  end

end