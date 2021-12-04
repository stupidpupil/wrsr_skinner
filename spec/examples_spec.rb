describe WRSRSkinner::Skinnable do

  describe 'when I fox-brand a IFA W50 (Covered)' do

    fox_brand = WRSRSkinner::Brand.new({
      cab_base:'#3a4f4f', 
      wooden_hull_base:'#3a4f4f', 
      logo:"rgb(180, 30, 0)", 
      base:"rgb(95%, 95%, 95%)", 
      stripe:"rgb(120, 140, 80)",
      logo_name: "fox"
      })

    ifa_w50_covered = WRSRSkinner::Skinnable.new("covered_ifa_w50")

    textures = ifa_w50_covered.textures_with_brand(fox_brand)

    it 'must match the reference image for base.dds' do
      textures['base.dds'].should.be same_image_as 'spec/reference/fox-covered_ifa_w50/base.dds.png'
    end

    it 'must match the reference image for covered.dds' do
      textures['covered.dds'].should.be same_image_as 'spec/reference/fox-covered_ifa_w50/covered.dds.png'
    end


  end

  describe 'when I brown-textile-brand a Skoda 706 (Covered trailer)' do

    brown_textile_brand = WRSRSkinner::Brand.new({
      base: "hsb(32, 74%, 70%)", 
      logo: "rgb(85%, 85%, 85%)",
      wooden_hull_base: "hsb(32, 40%, 60%)",
      logo_name: "textind"
    })

    covered_skd_706rttn = WRSRSkinner::Skinnable.new("covered_skd_706rttn")

    textures = covered_skd_706rttn.textures_with_brand(brown_textile_brand)

    it 'must match the reference image for covered.dds' do
      textures['covered.dds'].should.be same_image_as 'spec/reference/textile_brown-covered_skd_706rttn/covered.dds.png'
    end

  end

end