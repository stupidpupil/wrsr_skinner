require 'singleton'

module WRSRSkinner

  class Resolver
      include Singleton

      DEFAULT_PATHS = [
        __dir__ + "/../../data-raw/skinnable/",
        '/Program Files (x86)/Steam/steamapps/common/SovietRepublic/media_soviet/vehicles/',
        '/mnt/c/Program Files (x86)/Steam/steamapps/common/SovietRepublic/media_soviet/vehicles/'
      ]

      def initialize
        @paths = DEFAULT_PATHS

        if ENV['WRSR_RESOLVE_PATHS'] then
	  ENV['WRSR_RESOLVE_PATHS'].split(';').each {|p| self.add_path(p)}
        end
      end

      def add_path(new_path)
        @paths.push(new_path)
      end

      def resolve(target)
        @paths.each do |p|
          target_path = p + target
          return target_path if File.file? target_path
        end

        puts "Could not resolve #{target}"
        return nil
      end

  end

end
