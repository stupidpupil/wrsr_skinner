require 'RMagick'
require 'YAML'
require 'digest'

class TextureWrapper

  include Magick

  attr_reader :skinnable_dir, :texture_path, :texture_entry

  def initialize(skinnable_dir, texture_name)
    @skinnable_dir = skinnable_dir
    @texture_path = skinnable_dir + "/" + texture_name
    @texture_entry = YAML.load_file(skinnable_dir + "/skinner.yml")['textures'][texture_name]
  end

  def modulate_regions
    if self.texture_entry&.[]('modulate_regions').nil? then
      return []
    end

    self.texture_entry['modulate_regions'].map {|k,v| {
      geometry: k, 
      brightness: (v&.[]('brightness') || 1.0),
      saturation: (v&.[]('saturation') || 1.0),
      hue: (v&.[]('hue') || 1.0),
      mask: v&.[]('mask')
    }}

  end

  def color_regions

    if self.texture_entry&.[]('color_regions').nil? then
      return []
    end

    color_region_default = {
      color: 0,
      mask: nil
    }

    if self.texture_entry['color_regions'].is_a? Array then
      return self.texture_entry['color_regions'].map {|cr| color_region_default.merge(geometry: cr)}
    end

    self.texture_entry['color_regions'].map {|k,v| 
      color_region_default.merge({
        geometry: k, 
        color: ( v&.[]('color') || v&.[]('colour') ),
        mask: v&.[]('mask')
      }.compact)
    }

  end

  def logo_regions
    if self.texture_entry&.[]('logo_regions').nil? then
      return []
    end

    logo_region_default = {
      rotate: 0,
      worn: false,
      barrier: true,
      flip_x: false
    }

    if self.texture_entry['logo_regions'].is_a? Array then
      return self.texture_entry['logo_regions'].map {|lr| logo_region_default.merge(geometry: lr)}
    end

    self.texture_entry['logo_regions'].map {|k,v| 
      logo_region_default.merge({
        geometry: k, 
        rotate: v&.[]('rotate'),
        worn: v&.[]('worn'),
        barrier: v&.[]('barrier'),
        mask: v&.[]('mask'),
        flip_x: v&.[]('flip_x'),
      }.compact)
    }

  end

  def modulated_texture_cache_key
    Digest::SHA1.hexdigest(self.texture_path + self.modulate_regions.to_s)
  end

  def cache_file_ext
    ".mpc"
  end

  def modulated_texture_cache_path
    "./cache/mod_" + self.modulated_texture_cache_key + self.cache_file_ext
  end

  def texture_dimensions

    cache_path = self.modulated_texture_cache_path

    if File.file?(cache_path)
      texture = Image.read(cache_path).first
    else
      texture = Image.read(self.texture_path).first
    end

    {columns: texture.columns, rows: texture.rows}
  end

  def modulated_texture

    cache_path = self.modulated_texture_cache_path

    if File.file?(cache_path)
      texture = Image.read(cache_path).first
      texture.colorspace = RGBColorspace
      return(texture)
    end

    texture = Image.read(self.texture_path).first
    texture.colorspace = RGBColorspace

    orig_texture = texture

    self.modulate_regions.each_with_index do |drs, i|
      mod_texture = orig_texture.modulate(drs[:brightness], drs[:saturation], drs[:hue])
      mod_texture.alpha(ActivateAlphaChannel)

      mod_mask = Image.new(texture.columns, texture.rows) { |img|
        img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}

      if drs[:mask]
        supplied_mask = Image.read(self.skinnable_dir + "/" + drs[:mask]).first
        supplied_mask.alpha(ActivateAlphaChannel)
        mod_texture.composite!(supplied_mask, CenterGravity, DstOutCompositeOp)
      end

      drs_points = drs[:geometry].split(",").map {|e| eval(e).to_i}

      region = Magick::Draw.new
      
      if(drs_points.count == 4)
        region.rectangle(*drs_points)
      else
        region.polygon(*drs_points)
      end

      region.fill = 'white'
      region.draw(mod_mask)

      mod_texture.composite!(mod_mask, CenterGravity, DstInCompositeOp)
      texture.composite!(mod_texture, CenterGravity, OverCompositeOp)
    end

    texture.write(cache_path)
    return(texture)
  end

  def overlay_with_brand(brand)
    brand_logo_image = brand.logo_image

    dimensions = self.texture_dimensions

    overlay = Image.new(dimensions[:columns], dimensions[:rows]) { |img|
      img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}
    overlay.alpha(ActivateAlphaChannel)

    self.color_regions.group_by {|cr| cr[:color]}.each do |color_i, crs_for_color|

      region_color = brand.colors[color_i]

      color_overlay = Image.new(overlay.columns, overlay.rows) { |img|
        img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}

      color_overlay.alpha(ActivateAlphaChannel)

      if region_color.nil?
        region_color = 'transparent'
      end

      crs_for_color.each do |crs|
        crs_points = crs[:geometry].split(",").map {|e| eval(e).to_i}

        region = Magick::Draw.new
        
        region.fill = region_color

        if(crs_points.count == 4)
          region.rectangle(*crs_points)
        else
          region.polygon(*crs_points)
        end

        region.draw(color_overlay)

        if crs[:mask]
          supplied_mask = Image.read(self.skinnable_dir + "/" + crs[:mask]).first
          supplied_mask.alpha(ActivateAlphaChannel)
          color_overlay.composite!(supplied_mask, CenterGravity, DstOutCompositeOp)
        end
        
      end

      # For anything other than a base colour, we punch out logo barriers
      if (color_i%10) > 0 and not brand_logo_image.nil? then

        barrier_overlay = Image.new(overlay.columns, overlay.rows) { |img|
          img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}

        barrier_overlay.alpha(ActivateAlphaChannel)

        self.logo_regions.each do |lr|
          next if not lr[:barrier]
          
          region_points = lr[:geometry].split(",").map {|e| eval(e).to_i}

          lr_width = region_points[2] - region_points[0]
          lr_height = region_points[3] - region_points[1]

          lr_centre_x = region_points[0] + (lr_width/2).to_i
          lr_centre_y = region_points[1] + (lr_height/2).to_i

          # TODO Fix the inefficiency of actually doing this twice
          lg = brand_logo_image.rotate(lr[:rotate]).resize_to_fit(lr_width, lr_height) 

          region = Magick::Draw.new
          
          region.fill = brand.colors[0]

          region.circle(lr_centre_x,lr_centre_y, lr_centre_x+lg.columns/2, lr_centre_y+lg.rows/2)

          region.draw(barrier_overlay)

        end

        color_overlay.composite!(barrier_overlay, CenterGravity, DstOutCompositeOp)

      end

      overlay.composite!(color_overlay, CenterGravity, OverCompositeOp)
    end

    if not brand_logo_image.nil?
      self.logo_regions.each do |lr|

        lg = brand_logo_image.copy

        if lr[:worn] then
          worn_mask = Image.read("data-raw/worn_logo_mask.png").first
          worn_mask.resize!(brand_logo_image.columns, brand_logo_image.rows)
          worn_mask.alpha(ActivateAlphaChannel)
          worn_mask.fuzz = 50000
          worn_mask = worn_mask.transparent('black')

          lg.composite!(worn_mask, CenterGravity, DstInCompositeOp).modulate(0.8, 0.8, 1.0)
        end

        if lr[:flip_x] then
          lg.flop!
        end

        # Resize logo

        region_points = lr[:geometry].split(",").map {|e| eval(e).to_i}

        lr_width = region_points[2] - region_points[0]
        lr_height = region_points[3] - region_points[1]

        lg.rotate!(lr[:rotate]).resize_to_fit!(lr_width, lr_height)

        # Find centre of logo region
        lr_centre_x = region_points[0] + (lr_width/2).to_i
        lr_centre_y = region_points[1] + (lr_height/2).to_i

        # Adjust for CenterGravity
        lr_centre_x = lr_centre_x - (overlay.columns/2).to_i
        lr_centre_y = lr_centre_y - (overlay.rows/2).to_i

        overlay.composite!(lg, CenterGravity, lr_centre_x, lr_centre_y, OverCompositeOp)
      end
    end

    return(overlay)
  end

  def texture_with_brand(brand)

    texture = self.modulated_texture
    overlay = self.overlay_with_brand(brand)

    overlay.composite!(texture, CenterGravity, DstInCompositeOp)
    texture.composite!(overlay, CenterGravity, OverlayCompositeOp)

    texture.quantize(256, YUVColorspace, FloydSteinbergDitherMethod)
    texture.colorspace = RGBColorspace

    return(texture)

  end


end