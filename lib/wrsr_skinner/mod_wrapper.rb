module WRSRSkinner

  class ModWrapper

    def self.skinnable_ids_with_immediate_dependents(skinnable_ids)
      skinnable_ids.map {|i| Skinnable.new(i).depends_on}.inject(skinnable_ids, :+).uniq.sort
    end

    def self.skinnable_ids_with_all_dependents(skinnable_ids)
      ret = ModWrapper.skinnable_ids_with_immediate_dependents(skinnable_ids)

      if ModWrapper.skinnable_ids_with_immediate_dependents(ret) != ret
        return ModWrapper.skinnable_ids_with_all_dependents(ret)
      end

      return ret
    end

    # These constraints are meant to prevent returning any bundle
    # whose generation seems to have gone badly wrong
    BundleMaxFileCount = 200
    BundleMaxSizeBytes = 100*1024*1024

    def initialize(requested_skinnable_ids, brand, mod_id = nil, steam_owner_id = nil)

      if not requested_skinnable_ids.is_a? Array then
        raise "requested_skinnable_ids is not an Array!"
      end

      if requested_skinnable_ids.count > 16 then
        raise "requested_skinnable_ids has more than 16 members!"
      end

      @requested_skinnable_ids = requested_skinnable_ids
      @included_skinnable_ids = ModWrapper.skinnable_ids_with_all_dependents(requested_skinnable_ids)
      @brand = brand
      @mod_id = mod_id
      @steam_owner_id = steam_owner_id
    end

    def workshopconfig_as_s
      ret = ""

      ret << "$ITEM_ID #{@mod_id}\n\n"
      ret << "$OWNER_ID #{@steam_owner_id}\n\n"
      ret << "$ITEM_TYPE WORKSHOP_ITEMTYPE_VEHICLESKIN\n\n"
      ret << "$VISIBILITY 0\n\n"
      ret << "$ITEM_NAME \"WRSRSkinner generated mod\"\n\n"
      ret << "$ITEM_DESC \"WRSRSkinner generated mod\"\n\n"

      @requested_skinnable_ids.each do |skid|
        ret << "$TARGET_OBJECT_SKIN #{skid} #{skid}/material.mtl\n\n"
      end

      ret << "$END\n"

      return ret
    end

    def zip_io

      zip_io = StringIO.new

      Dir.mktmpdir() do |temp_dir|
        skinnables = @included_skinnable_ids.map { |sk| Skinnable.new(sk, temp_dir) }

        if Parallel then
          Parallel.each(skinnables,  in_processes: 6) {|s| s.save_textures_with_brand(@brand)}
        else
          skinnables.each {|s| s.save_textures_with_brand(@brand)}
        end

        File.open(temp_dir + "/workshopconfig", "w") { |f| f.puts self.workshopconfig_as_s }

        files_to_be_zipped = Dir[ File.join( temp_dir, "**", "**" ) ]

        break if files_to_be_zipped.count > BundleMaxFileCount
        files_to_be_zipped_size = files_to_be_zipped.map {|f| File.file?(f) ? File.size(f) : 0 }.inject(:+)
        break if files_to_be_zipped_size > BundleMaxSizeBytes

        Zip::File.open_buffer(zip_io) do |zip_file|
          files_to_be_zipped.each do |file|
            zip_file.add( file.sub( "#{ temp_dir }/", "" ), file )
          end
        end
        
      end

      zip_io.rewind
      return zip_io
    end

  end

end