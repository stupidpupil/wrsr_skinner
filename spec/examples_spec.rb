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

end