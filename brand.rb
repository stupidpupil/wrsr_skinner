require 'RMagick'

class Brand

  include Magick

  attr_reader :colors, :logo_name, :override_logo_flip_x, :logo_image

  def initialize(colors=['transparent', 'black'], logo_name=nil)

    if colors.is_a? Hash then
      colors = TextureWrapper::ColorLayers.map { |e| colors[e.to_sym] }
    end

    @colors = colors
    @logo_name = logo_name
    @logo_image = self.generate_logo_image.freeze
  end

  def logo_path
    "data-raw/logos/#{self.logo_name}.png"
  end

  def generate_logo_image
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

    overlay = Image.new(ret.columns, ret.rows) { |img| img.background_color = logo_color; }

    ret.composite(overlay, CenterGravity, MultiplyCompositeOp).composite(ret, CenterGravity, CopyAlphaCompositeOp)
  end

end