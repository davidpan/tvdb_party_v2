module TvdbPartyV2

  class Series
    attr_reader :client
    attr_accessor :id, :name, :overview, :seasons, :first_aired, :genres, :network, :rating, :runtime,
                  :actors, :banners, :air_time, :imdb_id, :ratingcount, :status, :airs_dayofweek

    def initialize(client, options = {})
      @client = client
      @id = options["id"]
      @name = options["seriesName"]
      @overview = options["overview"]
      @network = options["network"]
      @runtime = options["runtime"]
      @air_time = options['airsTime'] if options['airsTime']
      @imdb_id = options["imdbId"]
      @status = options["status"] if options["status"]
      @airs_dayofweek = options["airsDayOfWeek"]

      if options["genre"]
        @genres = options["genre"]
      else
        @genres = []
      end

      if options["siteRating"] && options["siteRating"] > 0
        @rating = options["siteRating"].to_f
      else
        @rating = 0
      end

      if options["siteRatingCount"] && options["siteRatingCount"] > 0
        @ratingcount = options["siteRatingCount"].to_f
      else
        @ratingcount = 0
      end

      begin
        @first_aired = Time.parse(options["firstAired"]).to_i
      rescue
        @first_aired = 0
      end
    end

    def episode(season_number, episode_number)
      client.get_episode(self, season_number, episode_number)
    end

    def posters
      client.get_banners(self, 'poster')
    end

    def fanart
      client.get_banners(self, 'fanart')
    end

    def series_banners
      client.get_banners(self, 'series')
    end

    def season_banners
      client.get_banners(self, 'season')
    end

    def seasonwide
      client.get_banners(self, 'seasonwide')
    end

    def season_posters(season_number)
      season_banners.select {|b| b.subkey == season_number.to_s}
    end

    def seasonwide_posters(season_number)
      seasonwide.select {|b| b.subkey == season_number.to_s}
    end


    def seasons
      client.get_seasons(self)
    end


    def actors
      client.get_actors(self)
    end

    def season(season_number)
      client.get_episode(self, season_number)
    end

  end

end
