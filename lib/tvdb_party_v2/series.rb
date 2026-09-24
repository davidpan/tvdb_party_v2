module TvdbPartyV2

  class Series
    attr_reader :client, :raw
    attr_accessor :id, :name, :overview, :first_aired, :genres, :network, :rating, :runtime,
                  :banners, :air_time, :imdb_id, :ratingcount, :status, :airs_dayofweek

    def initialize(client, options = {})
      @client = client
      @raw = options || {}
      @id = options["id"]
      @name = options["name"]
      @overview = options["overview"]
      @network = company_name(options["originalNetwork"])
      @runtime = options["averageRuntime"]
      @air_time = options['airsTime'] if options['airsTime']
      @imdb_id = RemoteId.imdb_from(options["remoteIds"])
      @status = status_name(options["status"])
      @airs_dayofweek = options["airsDays"]

      @genres = Array(options["genres"]).map { |g| g.is_a?(Hash) ? g["name"] : g }

      if options["score"] && options["score"] > 0
        @rating = options["score"].to_f
      else
        @rating = 0
      end

      @ratingcount = 0 # v4 no longer provides rating counts

      begin
        @first_aired = Time.parse(options["firstAired"].to_s).to_i
      rescue StandardError
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

    private

    def company_name(company)
      return nil unless company
      company.is_a?(Hash) ? company["name"] : company
    end

    def status_name(status)
      return nil unless status
      status.is_a?(Hash) ? status["name"] : status
    end
  end

end
