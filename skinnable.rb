require 'YAML'
require 'fileutils'

class Skinnable

  def self.all
    Dir.glob("*", base:"data-raw/skinnable/").map{|wrsr_path| Skinnable.new(wrsr_path)}
  end

  attr_reader :skinnable_wrsr_path, :skinnable_dir, :skinnable_entry, :skin_dir

  def initialize(skinnable_wrsr_path)
    @skinnable_wrsr_path = skinnable_wrsr_path #e.g. 'covered_ifa_w50'
    @skinnable_dir = "data-raw/skinnable/" + skinnable_wrsr_path
    @skinnable_entry = YAML.load_file(@skinnable_dir + "/skinner.yml")

    @skin_dir = "output/" + self.skinnable_wrsr_path
    FileUtils.mkdir_p(@skin_dir)
  end

  def save_textures_with_brand(br)

    self.skinnable_entry['textures'].keys.each do |tn|
      tw = TextureWrapper.new(self.skinnable_dir, tn)
      txtr = tw.texture_with_brand(br)
      txtr.write("DDS:" + @skin_dir + "/" + tn)
      txtr.write(@skin_dir + "/" + tn + ".png")
    end

  end

  def save_material()
    input = File.read(@skinnable_wrsr_path + 'material.mtl')

  end


end