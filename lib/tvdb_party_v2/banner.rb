module TvdbPartyV2
  class Banner
    attr_accessor :banner_type, :banner_resolution, :subkey, :path, :thumbnail_path, :ratingaverage, :ratingcount

    def initialize(options = {})
      @banner_type = options["keyType"]
      @banner_resolution = options["resolution"]
      @subkey = options["subKey"]
      @path = options["fileName"]

      if options["ratingsInfo"]["average"] && options["ratingsInfo"]["average"] > 0
        @ratingaverage = options["ratingsInfo"]["average"].to_f
      else
        @ratingaverage = 0
      end

      if options["ratingsInfo"]["count"] && options["ratingsInfo"]["count"] > 0
        @ratingcount = options["ratingsInfo"]["count"]
      else
        @ratingcount = 0
      end

    end

    def url
      "https://www.thetvdb.com/banners/" + @path
    end

    def thumb_url
      "https://www.thetvdb.com/banners/_cache/" + @path
    end

  end
end
