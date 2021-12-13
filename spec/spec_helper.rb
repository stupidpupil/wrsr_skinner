require 'bacon'
require 'rmagick'
require 'wrsr_skinner'

def same_image_as(path_to_image)

  lambda {|obj|
      other_image = Magick::Image.read(path_to_image).first

      other_image.to_blob() { |img| img.format = 'png'}

      obj.to_blob() { |img|
          img.format = 'DDS'
          img.define("dds", "compression", "dxt5")
          img.define("dds", "mipmaps", 1)
        }

      obj.to_blob() { |img| img.format = 'png'}

      diff = other_image.difference(obj)
      diff.all? { |di| di < 0.001 }
   }

end
