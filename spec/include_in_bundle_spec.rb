describe WRSRSkinner::Skinnable do

  describe 'when I choose the IFA W50 (Covered)' do

    ifa_w50_covered = WRSRSkinner::Skinnable.new("covered_ifa_w50")

    it 'must ask to be included in the bundle' do
      ifa_w50_covered.include_in_bundle?.should.eql true
    end
  end

  describe 'when I choose the preview pseudo-skinnable' do

    preview_pseudo = WRSRSkinner::Skinnable.new("preview")

    it 'must not ask to be included in the bundle' do
      preview_pseudo.include_in_bundle?.should.eql false
    end
  end


end