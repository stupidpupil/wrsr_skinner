describe WRSRSkinner::Skinnable do

  describe 'when I choose the IFA W50 (Open)' do

    open_ifa_w50 = WRSRSkinner::Skinnable.new("open_ifa_w50")

    it 'must depend_on the IFA W50 (Open)' do
      open_ifa_w50.depends_on.should.eql ['covered_ifa_w50']
    end
  end

  describe 'when I choose the IFA W50 (Covered)' do

    covered_ifa_w50 = WRSRSkinner::Skinnable.new("covered_ifa_w50")

    it 'must depend_on nothing' do
      covered_ifa_w50.depends_on.should.eql []
    end
  end


end