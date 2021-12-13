module WRSRSkinner

  module RegionGeom

    LengthExpRegexp = /\s*\d+(\s*[\+\/\-\*][\(\)]?\s*\d+[\(\)]?)*\s*/
    RectRegexp = /\A(?<x1>#{LengthExpRegexp}),(?<y1>#{LengthExpRegexp}),(?<x2>#{LengthExpRegexp}),(?<y2>#{LengthExpRegexp})\Z/
    CircleRegexp = /\AC(?<cx>#{LengthExpRegexp}),(?<cy>#{LengthExpRegexp}),(?<px>#{LengthExpRegexp}),(?<py>#{LengthExpRegexp})\Z/
    PolyRegexp = /\A((#{LengthExpRegexp}),)+#{LengthExpRegexp}\Z/

    def self.region_geom_from_string(in_str)

      if m = in_str.match(RectRegexp)
        return RegionGeomRect.new(m)
      end

      if m = in_str.match(CircleRegexp)
        return RegionGeomCircle.new(m)
      end

      if in_str.match(PolyRegexp)
        lengths_as_string = in_str.scan(/(#{LengthExpRegexp})/).map { |l| l.first }
        return RegionGeomPolygon.new(lengths_as_string)
      end

      raise "Couldn't understand RegionGeom: #{in_str}"
    end

    class RegionGeomRect

      attr_reader :points_hash

      def initialize(match_data)
        @points_hash = match_data.named_captures.map { |k,v| [k, eval(v).to_i] }.to_h
      end

      def draw(magick_draw)
        magick_draw.rectangle(*[points_hash['x1'], points_hash['y1'], points_hash['x2'], points_hash['y2']])
      end

      def x1
        points_hash['x1']
      end

      def x2
        points_hash['x2']
      end

      def y1
        points_hash['y1']
      end

      def y2
        points_hash['y2']
      end

      def width
        (x2-x1).abs
      end

      def height
        (y2-y1).abs
      end

      def cx
        [x1,x2].min + width/2
      end

      def cy
        [y1,y2].min + height/2
      end

    end

    class RegionGeomCircle

      attr_reader:points_hash

      def initialize(match_data)
        @points_hash = match_data.named_captures.map { |k,v| [k, eval(v).to_i] }.to_h
      end

      def draw(magick_draw)
        magick_draw.circle(*[points_hash['cx'], points_hash['cy'], points_hash['px'], points_hash['py']])
      end
    end

    class RegionGeomPolygon

      attr_reader :lengths

      def initialize(lengths_as_string)
        @lengths = lengths_as_string.map { |l| eval(l).to_i }
      end

      def draw(magick_draw)
        magick_draw.polygon(*self.lengths)
      end
    end

  end

end
