module TvdbPartyV2

  class Episode
    attr_reader :client
    attr_accessor :id, :season_number, :number, :name, :overview, :air_date, :thumb, :guest_stars, :director, :writer, :imdb_id, :rating, :ratingcount, :season_id

    def initialize(client, options = {})
      @client = client
      @id = options["id"]
      @season_number = options["airedSeason"]
      @number = options["airedEpisodeNumber"]
      @name = options["episodeName"]
      @overview = options["overview"]
      @director = options["directors"]
      @writer = options["writers"]
      @series_id = options["seriesId"]
      @season_id = options["airedSeasonID"]
      @imdb_id = options["imdbId"]
      if options["guestStars"]
        @guest_stars = options["guestStars"]
      else
        @guest_stars = []
      end

      if options["filename"].nil? || options["filename"].empty?
        @thumb = nil
      else
        @thumb = "http://www.thetvdb.com/banners/" + options["filename"]
      end

      begin
        @air_date = Time.parse(options["firstAired"]).to_i
      rescue
        @air_date = 0
      end

      if options["siteRating"] && options["siteRating"] > 0
        @rating = options["siteRating"].to_f
      else
        @rating = 0
      end

      if options["siteRatingCount"] && options["siteRatingCount"] > 0
        @ratingcount = options["siteRatingCount"]
      else
        @ratingcount = 0
      end

    end

    def series
      client.get_series_by_id(@series.id)
    end
  end

end
