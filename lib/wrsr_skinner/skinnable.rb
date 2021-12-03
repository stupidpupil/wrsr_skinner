module WRSRSkinner

  class Skinnable

    BaseDir = __dir__ + "/../../data-raw/skinnable/"
    OutputDir = __dir__ + "/../../output/"

    def self.all
      Dir.glob("*", base:BaseDir).map{|wrsr_path| Skinnable.new(wrsr_path)}
    end

    attr_reader :skinnable_wrsr_path, :skinnable_dir, :skinnable_entry, :skin_dir

    def initialize(skinnable_wrsr_path)
      @skinnable_wrsr_path = skinnable_wrsr_path #e.g. 'covered_ifa_w50'
      @skinnable_dir = BaseDir + skinnable_wrsr_path
      @skinnable_entry = YAML.load_file(@skinnable_dir + "/skinner.yml")

      @skin_dir = OutputDir + self.skinnable_wrsr_path
      FileUtils.mkdir_p(@skin_dir)
    end

    def textures_with_brand(br)
      return {} if self.skinnable_entry['textures'].nil?

      ret = {}

      self.skinnable_entry['textures'].keys.each do |tn|
        tw = TextureWrapper.new(self.skinnable_dir, tn)
        ret[tn] = tw.texture_with_brand(br)
      end

      return(ret)
    end

    def save_textures_with_brand(br)
      self.textures_with_brand(br).each_pair do |tn, txtr|
        txtr.write("DDS:" + @skin_dir + "/" + tn) { |img|
          img.define("dds", "compression", "dxt1")
          img.define("dds", "mipmaps", 1)
        }
        txtr.write(@skin_dir + "/" + tn + ".png")
      end
    end

    def save_material()
      input = File.read(@skinnable_wrsr_path + 'material.mtl')

    end

  end

end
