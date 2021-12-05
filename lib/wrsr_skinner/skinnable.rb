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
      @skinnable_entry = YAML.load_file(@skinnable_dir + "/skinner.yml")

      @skin_dir = output_dir_base + '/' + self.skinnable_wrsr_path
      FileUtils.mkdir_p(@skin_dir)
    end

    def include_in_bundle?
      skinnable_entry['include_in_bundle'].nil? ? true : skinnable_entry['include_in_bundle']
    end

    def texture_wrappers
      return {} if self.skinnable_entry['textures'].nil?

      ret = {}

      self.skinnable_entry['textures'].keys.each do |tn|
        ret[tn] = TextureWrapper.new(self.skinnable_dir, tn)
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
          img.define("dds", "compression", "dxt1")
          img.define("dds", "mipmaps", 1)
        }
        txtr.write(@skin_dir + "/" + tn + ".png")
      end

      if File.file? @skinnable_dir + '/material.mtl'
        FileUtils.cp @skinnable_dir + '/material.mtl', @skin_dir + '/material.mtl'
      end
    end

    def save_material()
      input = File.read(@skinnable_wrsr_path + 'material.mtl')

    end

  end

end
