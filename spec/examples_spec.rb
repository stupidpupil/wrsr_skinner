describe WRSRSkinner::Skinnable do

  describe 'when I fox-brand a IFA W50 (Covered)' do

    fox_brand = WRSRSkinner::Brand.new({
      cab_base:'#3a4f4f', 
      wooden_hull_base:'#3a4f4f', 
      logo:"rgb(180, 30, 0)", 
      base:"rgb(95%, 95%, 95%)", 
      stripe:"rgb(120, 140, 80)"}, 
      "fox"
      )

    ifa_w50_covered = WRSRSkinner::Skinnable.new("covered_ifa_w50")

    textures = ifa_w50_covered.textures_with_brand(fox_brand)
    signatures = textures.map {|k,v| [k, v.signature]}.to_h

    it 'must give the correct signature for base.dds' do
      signatures['base.dds'].should.equal '80497bf87cd366f591a9a56f3ec2ee279ce4f3945ec1de7415e7110b93d452f3'
    end

    it 'must give the correct signature for covered.dds' do
      signatures['covered.dds'].should.equal '5a76cfba6be8f5c75bdd029fc8723cf81f5ba1f3feaaba43a114b4b0ef84d254'
    end


  end

  describe 'when I brown-textile-brand a Skoda 706 (Covered trailer)' do

    brown_textile_brand = WRSRSkinner::Brand.new({
      base: "hsb(32, 74%, 70%)", 
      logo: "rgb(85%, 85%, 85%)",
      wooden_hull_base: "hsb(32, 40%, 60%)"
    }, "textind")

    covered_skd_706rttn = WRSRSkinner::Skinnable.new("covered_skd_706rttn")

    textures = covered_skd_706rttn.textures_with_brand(brown_textile_brand)
    signatures = textures.map {|k,v| [k, v.signature]}.to_h

    it 'must give the correct signature for covered.dds' do
      signatures['covered.dds'].should.equal '23642dcfdf7e86a5ec847b13a3d48da3619a2a6ed6d9c771d9e4aadbef5b6f2f'
    end

  end

end