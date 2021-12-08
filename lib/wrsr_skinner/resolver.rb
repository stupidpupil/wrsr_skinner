require 'singleton'

module WRSRSkinner

  class Resolver
      include Singleton

      DEFAULT_PATHS = [__dir__ + "/../../data-raw/skinnable/"]

      def initialize
        @paths = DEFAULT_PATHS
      end

      def add_path(new_path)
        @paths.push(new_path)
      end

      def resolve(target)
        @paths.each do |p|
          target_path = p + target
          return target_path if File.file? target_path
        end

        return nil
      end

  end

end