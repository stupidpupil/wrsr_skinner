require 'RMagick'

class Brand

  include Magick

  attr_reader :colors, :logo_name, :override_logo_flip_x

  def initialize(colors=['transparent', 'black'], logo_name=nil)

    color_translate = {
      base: 0,
      logo: 1,
      stripe: 2,
      wooden_hull_base: 70,
      cab_base: 50,
      cab_stripe_base: 60
    }

    if colors.is_a? Hash then
      ch = colors

      colors = []

      color_translate.each_pair do |k,v|
        colors[v] = ch[k]
      end

    end

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

    overlay = Image.new(ret.columns, ret.rows) { |img| img.background_color = logo_color; }

    ret.composite(overlay, CenterGravity, MultiplyCompositeOp).composite(ret, CenterGravity, CopyAlphaCompositeOp)
  end

end