module TvdbPartyV2

  class Season
    attr_reader :client, :raw
    attr_accessor :id, :number, :name, :series_id, :image, :year

    def initialize(client, options = {})
      @client = client
      @raw = options || {}
      @id = options["id"]
      @number = options["number"]
      @name = options["name"]
      @series_id = options["seriesId"]
      @image = options["image"]
      @year = options["year"]
    end

    # Episodes in this season (v4 returns them in the season extended record)
    def episodes
      eps = @raw["episodes"]
      return [] unless eps.is_a?(Array)
      eps.map { |e| Episode.new(client, e) }
    end
  end

end
