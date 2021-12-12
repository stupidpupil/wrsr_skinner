module WRSRSkinner

  class Skinnable

    BaseDir = __dir__ + "/../../data-raw/skinnable/"
    DefaultOutputDirBase = __dir__ + "/../../output/"

    def self.all(output_dir_base = DefaultOutputDirBase)
      Dir.glob("*", base:BaseDir).map{|wrsr_path| Skinnable.new(wrsr_path, output_dir_base)}
    end

    attr_reader :skinnable_wrsr_path, :skinnable_dir, :skinnable_entry, :skin_dir

    def initialize(skinnable_wrsr_path, output_dir_base = DefaultOutputDirBase)
      @skinnable_wrsr_path = skinnable_wrsr_path #e.g. 'covered_ifa_w50'
      @skinnable_dir = BaseDir + skinnable_wrsr_path

      if File.file?(@skinnable_dir + "/skinner.yml")
        @skinnable_entry = YAML.load_file(@skinnable_dir + "/skinner.yml")
      else
        @skinnable_entry = {}
      end

      @skin_dir = output_dir_base + '/' + self.skinnable_wrsr_path
    end

    def vehicle_family
      return skinnable_entry['family'] unless skinnable_entry['family'].nil?
      path_parts = skinnable_wrsr_path.split('_')
      return self.skinnable_wrsr_path if path_parts.length < 3
      return 'kmz_5320_5410' if path_parts[1] == 'kmz' and ['5320', '5410'].include? path_parts[2]
      ret = self.skinnable_wrsr_path.split('_')[1,2].join('_')
      ret.gsub(/706(rt(tn)?)?\Z/, "706rt")
    end

    ValidVehicleTypes = ['bus', 'cement', 'covered', 'gravel', 'oil', 'open', 'refrig', 'snow']

    def vehicle_type
      path_parts = skinnable_wrsr_path.split('_')
      return path_parts[0] if ValidVehicleTypes.include? path_parts[0]
      return 'unknown'
    end

    def depends_on
      return [] if not File.file? @skinnable_dir + '/material.mtl'
      File.readlines(@skinnable_dir + '/material.mtl').
        map { |l| l.match(/\A\$TEXTURE_MTL \d \.\.\/(.+?)\/.+\Z/)&.[](1)}.
        compact.uniq
    end

    def include_in_bundle?
      skinnable_entry['include_in_bundle'].nil? ? true : skinnable_entry['include_in_bundle']
    end

    def texture_wrappers
      return {} if self.skinnable_entry['textures'].nil?

      ret = {}

      self.skinnable_entry['textures'].keys.each do |tn|
        ret[tn] = TextureWrapper.new(self.skinnable_wrsr_path, tn)
      end

      return ret
    end

    def textures_with_brand(br)
      self.texture_wrappers.map {|k,v| [k,v.texture_with_brand(br)]}.to_h
    end

    def save_textures_with_brand(br)
      FileUtils.mkdir_p @skin_dir

      self.textures_with_brand(br).each_pair do |tn, txtr|
        txtr.write("DDS:" + @skin_dir + "/" + tn) { |img|
          img.define("dds", "compression", "dxt5")
          img.define("dds", "mipmaps", 1)
        }
        txtr.write(@skin_dir + "/" + tn + ".png")
      end

      if File.file? @skinnable_dir + '/material.mtl'
        FileUtils.cp @skinnable_dir + '/material.mtl', @skin_dir + '/material.mtl'
      end
    end

    def save_material()
      FileUtils.mkdir_p(@skin_dir)
      input = File.read(@skinnable_wrsr_path + 'material.mtl')
    end

  end

end
