module TvdbPartyV2

  class Movie
    attr_reader :client, :raw
    attr_accessor :id, :name, :overview, :status, :runtime, :year, :genres, :image, :imdb_id, :rating, :first_release

    def initialize(client, options = {})
      @client = client
      @raw = options || {}
      @id = options["id"]
      @name = options["name"]
      @overview = options["overview"]
      @status = status_name(options["status"])
      @runtime = options["runtime"]
      @year = options["year"]
      @image = options["image"]
      @imdb_id = RemoteId.imdb_from(options["remoteIds"])
      @genres = Array(options["genres"]).map { |g| g.is_a?(Hash) ? g["name"] : g }

      if options["score"] && options["score"] > 0
        @rating = options["score"].to_f
      else
        @rating = 0
      end

      release = options["first_release"]
      begin
        @first_release = Time.parse(release.is_a?(Hash) ? release["date"].to_s : release.to_s).to_i
      rescue StandardError
        @first_release = 0
      end
    end

    private

    def status_name(status)
      return nil unless status
      status.is_a?(Hash) ? status["name"] : status
    end
  end

end
