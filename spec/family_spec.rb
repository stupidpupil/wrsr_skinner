describe WRSRSkinner::Skinnable do

  describe 'when I choose the IFA W50 (Covered)' do

    ifa_w50_covered = WRSRSkinner::Skinnable.new("covered_ifa_w50")

    it 'must have a family of ifa_w50' do
      ifa_w50_covered.vehicle_family.should.eql 'ifa_w50'
    end
  end

  describe 'when I choose the Skoda 706 RT (Open)' do

    open_skd_706_rt = WRSRSkinner::Skinnable.new("open_skd_706_rt")

    it 'must have a family of skd_706rt' do
      open_skd_706_rt.vehicle_family.should.eql 'skd_706rt'
    end
  end

  describe 'when I choose the Skoda 706 Snowplow' do

    snow_skd_706 = WRSRSkinner::Skinnable.new("snow_skd_706")

    it 'must have a family of skd_706rt' do
      snow_skd_706.vehicle_family.should.eql 'skd_706rt'
    end
  end


  describe 'when I choose the Skoda 706 RTTN (Open Trailer)' do

    open_skd_706_rttn = WRSRSkinner::Skinnable.new("open_skd_706rttn")

    it 'must have a family of skd_706rt' do
      open_skd_706_rttn.vehicle_family.should.eql 'skd_706rt'
    end
  end


  describe 'when I choose the preview pseudo-skinnable' do

    preview_pseudo = WRSRSkinner::Skinnable.new("preview")

    it 'must have a family of preview' do
      preview_pseudo.vehicle_family.should.eql 'preview'
    end
  end


end