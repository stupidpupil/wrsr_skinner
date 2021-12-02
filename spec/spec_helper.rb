require 'bacon'
require 'rmagick'
require 'wrsr_skinner'

def same_image_as(path_to_image)

  lambda {|obj|
      # This is a bit of a hack
      obj = Magick::Image.from_blob(obj.to_blob {|b| b.format = 'png'; b.depth = 8}).first

      other_image = Magick::Image.read(path_to_image).first
      diff = other_image.difference(obj)
      diff[0] < 0.0001 and diff[2] < 0.04 and diff[1] < 0.0001
   }

end
