module TvdbPartyV2
  class Banner
    attr_accessor :banner_type, :banner_resolution, :subkey, :path, :thumbnail_path, :ratingaverage, :ratingcount, :season_id

    # v4 artwork record: image/thumbnail are paths, type is an integer type id
    def initialize(options = {})
      @banner_type = options["type"]
      @banner_resolution = options["width"] && options["height"] ? "#{options["width"]}x#{options["height"]}" : nil
      @path = options["image"]
      @thumbnail_path = options["thumbnail"]
      @season_id = options["seasonId"]

      if options["score"] && options["score"] > 0
        @ratingaverage = options["score"].to_f
      else
        @ratingaverage = 0
      end

      @ratingcount = 0 # v4 no longer provides rating counts
    end

    def url
      banner_path_url(@path)
    end

    def thumb_url
      banner_path_url(@thumbnail_path, cache: true)
    end

    private

    def banner_path_url(path, cache: false)
      return nil unless path
      return path if path.start_with?('http')
      path = "_cache/#{path}" if cache && !path.start_with?('_cache/')
      "https://www.thetvdb.com/banners/" + path
    end

  end
end
