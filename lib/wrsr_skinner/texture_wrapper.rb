module WRSRSkinner

  class TextureWrapper

    ColorLayers = [
      'base',
      'logo',
      'stripe',
      'wooden_hull_base',
      'cab_base',
      'cab_stripe_base',
      'cab_stripe_logo'
    ]

    include Magick

    attr_reader :skinnable_wrsr_path, :texture_path, :texture_entry

    def initialize(skinnable_wrsr_path, texture_name)
      @skinnable_wrsr_path = skinnable_wrsr_path
      @texture_entry = YAML.load_file(Resolver.instance.resolve(skinnable_wrsr_path + "/skinner.yml"))['textures'][texture_name]

      texture_path = @texture_entry&.[]('path') || texture_name
      @texture_path = Resolver.instance.resolve(skinnable_wrsr_path + "/" + texture_path)

      if @texture_path.nil?
        raise "Couldn't find texture #{texture_name} for #{skinnable_wrsr_path}"
      end

    end

    def modulate_regions
      if self.texture_entry&.[]('modulate_regions').nil? then
        return []
      end

      self.texture_entry['modulate_regions'].map {|k,v| {
        geometry_str: k,
        geometry: RegionGeom.region_geom_from_string(k), 
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
        layer: 'base',
        mask: nil
      }

      if self.texture_entry['color_regions'].is_a? Array then
        return self.texture_entry['color_regions'].
          map {|cr| color_region_default.merge(geometry_str: cr, geometry: RegionGeom.region_geom_from_string(cr))}
      end

      self.texture_entry['color_regions'].map {|k,v| 
        color_region_default.merge({
          geometry_str: k,
          geometry: RegionGeom.region_geom_from_string(k), 
          layer: v&.[]('layer'),
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
        flip_x: false,
        layer: 'logo',
        squish: 1.0
      }

      if self.texture_entry['logo_regions'].is_a? Array then
        return self.texture_entry['logo_regions'].
          map {|lr| logo_region_default.merge(geometry_str: lr, geometry: RegionGeom.region_geom_from_string(lr))}
      end

      self.texture_entry['logo_regions'].map {|k,v| 
        logo_region_default.merge({
          geometry_str: k, 
          geometry: RegionGeom.region_geom_from_string(k),
          rotate: v&.[]('rotate'),
          worn: v&.[]('worn'),
          barrier: v&.[]('barrier'),
          mask: v&.[]('mask'),
          flip_x: v&.[]('flip_x'),
          layer: v&.[]('layer'),
          squish: v&.[]('squish')
        }.compact)
      }

    end

    def modulated_texture_cache_key
      Digest::SHA1.hexdigest(self.texture_path + self.modulate_regions.filter { |k| k != 'geometry' }.to_s)
    end

    def cache_file_ext
      ".mpc"
    end

    CacheDir = __dir__ + "/../../cache/"

    def modulated_texture_cache_path
      CacheDir + "/mod_" + self.modulated_texture_cache_key + self.cache_file_ext
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
          supplied_mask = Image.read(Resolver.instance.resolve(self.skinnable_wrsr_path + "/" + drs[:mask])).first
          supplied_mask.alpha(ActivateAlphaChannel)
          mod_texture.composite!(supplied_mask, CenterGravity, DstOutCompositeOp)
        end

        region = Magick::Draw.new
        
        drs[:geometry].draw(region)

        region.fill = 'white'
        region.draw(mod_mask)

        mod_texture.composite!(mod_mask, CenterGravity, DstInCompositeOp)
        texture.composite!(mod_texture, CenterGravity, OverCompositeOp)
      end

      texture.write(cache_path)
      return(texture)
    end

    def overlay_with_brand(brand)

      if brand.logo.nil?
        logo_regions_with_brand = []
      else
        logo_regions_with_brand = self.logo_regions
        logo_regions_with_brand.each do |lr|
          lr[:color] = brand.colors[lr[:layer]]
        end

        logo_regions_with_brand.delete_if {|lr| lr[:color].nil? or lr[:color] == 'transparent'}
      end

      dimensions = self.texture_dimensions

      overlay = Image.new(dimensions[:columns], dimensions[:rows]) { |img|
        img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}
      overlay.alpha(ActivateAlphaChannel)

      col_reg = self.color_regions
      col_reg.each { |cr|  cr[:color] = ColorLayers.index(cr[:layer])}

      col_reg.group_by {|cr| cr[:color]}.each do |color_i, crs_for_color|

        region_color = brand.colors[crs_for_color[0][:layer]]

        color_overlay = Image.new(overlay.columns, overlay.rows) { |img|
          img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}

        color_overlay.alpha(ActivateAlphaChannel)

        if region_color.nil?
          region_color = 'transparent'
        end

        crs_for_color.each do |crs|

          region = Magick::Draw.new
          
          region.fill = region_color

          crs[:geometry].draw(region)

          region.draw(color_overlay)

          if crs[:mask]
            # BUG: This will mask out any color region of the same layer+color
            # This isn't likely to matter much in practice, and is probably
            # quite easy to workaround anyway
            supplied_mask = Image.read(Resolver.instance.resolve(self.skinnable_wrsr_path + "/" + crs[:mask])).first
            supplied_mask.alpha(ActivateAlphaChannel)
            color_overlay.composite!(supplied_mask, CenterGravity, DstOutCompositeOp)
          end
          
        end

        # For anything other than a base colour, we punch out logo barriers
        if not (crs_for_color[0][:layer] =~ /(^|_)base(_|$)/) then

          barrier_overlay = Image.new(overlay.columns, overlay.rows) { |img|
            img.depth=16; img.colorspace = RGBColorspace; img.background_color='transparent'}

          barrier_overlay.alpha(ActivateAlphaChannel)

          logo_regions_with_brand.each do |lr|
            next if not lr[:barrier]
        
            # TODO Fix the inefficiency of actually doing this twice
            lg = brand.logo.logo_mask.copy

            if lr[:squish] != 1.0 then
              lg.resize!(lg.columns*lr[:squish], lg.rows)
            end

            lg = lg.rotate(lr[:rotate]).resize_to_fit(lr[:geometry].width, lr[:geometry].height) 

            region = Magick::Draw.new
            
            region.fill = 'white'

            region.circle(lr[:geometry].cx, lr[:geometry].cy, lr[:geometry].cx+lg.columns/2, lr[:geometry].cy+lg.rows/2)

            region.draw(barrier_overlay)

          end

          color_overlay.composite!(barrier_overlay, CenterGravity, DstOutCompositeOp)

        end

        overlay.composite!(color_overlay, CenterGravity, OverCompositeOp)
      end

      logo_regions_with_brand.each do |lr|

        lg = brand.logo.logo_with_color(lr[:color])

        if lr[:squish] != 1.0 then
          lg.resize!(lg.columns*lr[:squish], lg.rows)
        end

        if lr[:worn] then
          worn_mask = Image.read(__dir__ + "/../../data-raw/worn_logo_mask.png").first
          worn_mask.resize!(lg.columns, lg.rows)
          worn_mask.alpha(ActivateAlphaChannel)
          worn_mask.fuzz = 50000
          worn_mask = worn_mask.transparent('black')

          lg.composite!(worn_mask, CenterGravity, DstInCompositeOp).modulate(0.8, 0.8, 1.0)
        end

        if lr[:flip_x] then
          lg.flop!
        end

        # Resize logo

        lg.rotate!(lr[:rotate]).resize_to_fit!(lr[:geometry].width, lr[:geometry].height)

        # Adjust for CenterGravity
        lr_centre_x = lr[:geometry].cx - (overlay.columns/2).to_i
        lr_centre_y = lr[:geometry].cy - (overlay.rows/2).to_i

        overlay.composite!(lg, CenterGravity, lr_centre_x, lr_centre_y, OverCompositeOp)
      end

      return(overlay)
    end

    def texture_with_brand(brand)

      texture = self.modulated_texture
      overlay = self.overlay_with_brand(brand)

      overlay.composite!(texture, CenterGravity, DstInCompositeOp)
      texture.composite!(overlay, CenterGravity, OverlayCompositeOp)

      texture.colorspace = RGBColorspace

      return(texture)

    end

  end
end