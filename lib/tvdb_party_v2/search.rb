module TvdbPartyV2

  class Search
    include HTTParty
    base_uri 'https://api4.thetvdb.com/v4'
    headers "Content-Type" => "application/json"
    attr_accessor :token, :language

    # v4 auth: apikey required, subscribers may pass a pin; v2's username/userkey are gone
    def initialize(apikey, pin = nil, language = 'en')
      @language = language
      body = { "apikey" => apikey }
      body["pin"] = pin unless pin.nil? || pin.to_s.empty?
      thetvdb = self.class.post('/login', :body => body.to_json)
      @token = thetvdb.dig('data', 'token')
    end

    # Search series (or movies via type: 'movie') by name
    def search(series_name, type = 'series')
      response = self.get("/search?query=#{URI.encode_www_form_component(series_name)}&type=#{type}")
      normalize_results(response)
    end

    # Search series by imdb id (remote_id looks like imdb-tt1796960)
    def search_by_imdb(imdb_id)
      response = self.get("/search?remote_id=#{RemoteId.for_imdb(imdb_id)}&type=series")
      normalize_results(response)
    end

    # Search movies by name
    def search_movies(movie_name)
      search(movie_name, 'movie')
    end

    # Get series details by series id
    def get_series_by_id(series_id, language = self.language)
      fetch_entity("/series/#{series_id}/extended", Series)
    end

    # Get episode details by episode id
    def get_episode_by_id(episode_id, language = self.language)
      fetch_entity("/episodes/#{episode_id}/extended", Episode)
    end

    # Get movie details by movie id
    def get_movie_by_id(movie_id)
      fetch_entity("/movies/#{movie_id}/extended", Movie)
    end

    # Get season details (with episodes) by season id
    def get_season_by_id(season_id)
      fetch_entity("/seasons/#{season_id}/extended", Season)
    end

    # Get episodes of a season/episode number (season_type: default/official/alternate/regional)
    def get_episode(series, season_number, episode_number = nil, page = nil, season_type = 'default')
      episodes = []
      loop do
        url = "/series/#{series.id}/episodes/#{season_type}?season=#{season_number}"
        url = url + "&episodeNumber=#{episode_number}" if episode_number
        url = url + "&page=#{page}" unless page.nil?

        response = self.get(url)
        data = response.dig('data', 'episodes') || []
        episodes.concat(data)

        next_page = response.dig('links', 'next')
        break if next_page.nil? || next_page == false || next_page.to_s.empty? || data.empty?
        page = next_page
      end
      episodes.map { |e| self.get_episode_by_id(e["id"]) }
    end

    # Get actors (v4 returns them in the series extended record's characters)
    def get_actors(series)
      characters = series_data(series)["characters"]
      return [] unless characters.is_a?(Array)
      characters.collect { |c| Actor.new(c) }
    end

    # Get season numbers
    def get_seasons(series)
      seasons = series_data(series)["seasons"]
      return [] unless seasons.is_a?(Array)
      seasons.map { |s| s.is_a?(Hash) ? s["number"] : s }
    end

    # Get posters/banners etc. (v4 uses /series/{id}/artworks with integer type ids)
    def get_banners(series, keyType, subKey = nil)
      url = "/series/#{series.id}/artworks"
      type_id = ARTWORK_TYPES[keyType.to_s.downcase]
      url = url + "?type=#{type_id}" if type_id

      response = self.get(url)
      data = response && response["data"]
      return [] unless data

      season_numbers = {}
      Array(data["seasons"]).each do |s|
        season_numbers[s["id"]] = s["number"] if s.is_a?(Hash)
      end

      artworks = data["artworks"].is_a?(Array) ? data["artworks"] : []
      banners = artworks.map { |result| Banner.new(result) }
      banners.each do |b|
        b.subkey = season_numbers[b.season_id].to_s if b.season_id && season_numbers.key?(b.season_id)
      end
      banners = banners.select { |b| b.subkey == subKey.to_s } unless subKey.nil?
      banners
    end

    # List movies (movies are a v4-only entity)
    def movies(page = nil)
      url = "/movies"
      url = url + "?page=#{page}" unless page.nil?
      response = self.get(url)
      data = response && response["data"]
      return [] unless data.is_a?(Array)
      data.map { |result| Movie.new(self, result) }
    end

    def get(url)
      return self.class.get(url,
                     :headers => {"Authorization" => 'Bearer ' + @token,"Accept-Language" => self.language}).parsed_response
    end

    private

    # v4 classic artwork type ids (full list at /artwork/types)
    ARTWORK_TYPES = {
      'series' => 1,
      'poster' => 2,
      'fanart' => 3,
      'season' => 6,
      'seasonwide' => 7
    }.freeze

    def normalize_results(response)
      data = response && response["data"]
      return [] unless data
      case data
      when Array
        data
      when Hash
        [data]
      else
        []
      end
    end

    def fetch_entity(path, klass)
      response = self.get(path)
      response && response["data"] ? klass.new(self, response["data"]) : nil
    end

    def series_data(series)
      raw = series.raw if series.respond_to?(:raw)
      return raw if raw.is_a?(Hash) && !raw.empty?
      response = self.get("/series/#{series.id}/extended")
      (response && response["data"]) || {}
    end
  end
end
