describe WRSRSkinner::RegionGeom do

  describe "when I have a RegionGeom string of '1,2,3,4'" do

    rg = WRSRSkinner::RegionGeom.region_geom_from_string('1,2,3,4')

    it 'must return a RegionGeomRect' do
      rg.class.should.eql WRSRSkinner::RegionGeom::RegionGeomRect
    end

    it 'must produce a points hash of {"x1"=>1, "y1"=>2, "x2"=>3, "y2"=>4}' do
      rg.points_hash.should.eql ({"x1"=>1, "y1"=>2, "x2"=>3, "y2"=>4})
    end

  end

  describe "when I have a RegionGeom string of '1,2,1+2,2+2'" do

    rg = WRSRSkinner::RegionGeom.region_geom_from_string('1,2,1+2,2+2')

    it 'must return a RegionGeomRect' do
      rg.class.should.eql WRSRSkinner::RegionGeom::RegionGeomRect
    end

    it 'must produce a points hash of {"x1"=>1, "y1"=>2, "x2"=>3, "y2"=>4}' do
      rg.points_hash.should.eql ({"x1"=>1, "y1"=>2, "x2"=>3, "y2"=>4})
    end

  end

  describe "when I have a RegionGeom string of '1,2,1+2,system('beep')'" do

    it 'must return a RegionGeomRect' do
      lambda { rg = WRSRSkinner::RegionGeom.region_geom_from_string('1,2,1+2,system(\'beep\')') }.
        should.raise Exception
    end

  end

  describe "when I have a RegionGeom string of '1,2, 3,4, 5,6'" do

    rg = WRSRSkinner::RegionGeom.region_geom_from_string('1,2, 3,4, 5,6')

    it 'must return a RegionGeomPolygon' do
      rg.class.should.eql WRSRSkinner::RegionGeom::RegionGeomPolygon
    end

    it 'must return an array of lengths of [1,2,3,4,5,6]' do
      rg.lengths.should.eql [1,2,3,4,5,6]
    end


  end


end