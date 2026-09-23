module TvdbPartyV2

  class Episode
    attr_reader :client
    attr_accessor :id, :season_number, :number, :name, :overview, :air_date, :thumb, :guest_stars, :director, :writer, :imdb_id, :rating, :ratingcount, :season_id

    def initialize(client, options = {})
      @client = client
      @id = options["id"]
      @season_number = options["seasonNumber"]
      @number = options["number"]
      @name = options["name"]
      @overview = options["overview"]
      @series_id = options["seriesId"]
      @season_id = season_id_from(options["seasons"])
      @imdb_id = RemoteId.imdb_from(options["remoteIds"])
      @guest_stars = guest_stars_from(options["characters"])

      if options["image"].nil? || options["image"].empty?
        @thumb = nil
      else
        @thumb = "https://www.thetvdb.com/banners/" + options["image"]
      end

      # v4 剧集记录不再提供导演/编剧字符串数组
      @director = nil
      @writer = nil

      begin
        @air_date = Time.parse(options["aired"].to_s).to_i
      rescue StandardError
        @air_date = 0
      end

      if options["score"] && options["score"] > 0
        @rating = options["score"].to_f
      else
        @rating = 0
      end

      @ratingcount = 0 # v4 不再提供评分计数
    end

    def series
      client.get_series_by_id(@series_id)
    end

    private

    def season_id_from(seasons)
      first = Array(seasons).first
      first.is_a?(Hash) ? first["id"] : first
    end

    def guest_stars_from(characters)
      Array(characters).select do |c|
        next false unless c.is_a?(Hash)
        type = c["peopleType"]
        type = type["name"] if type.is_a?(Hash)
        type.to_s =~ /guest/i
      end.map { |c| c["personName"] }
    end
  end

end
