module TvdbPartyV2

  class Search
    include HTTParty
    base_uri 'https://api4.thetvdb.com/v4'
    headers "Content-Type" => "application/json"
    attr_accessor :token, :language

    # v4 认证:apikey 必填,订阅用户可传 pin;不再使用 v2 的 username/userkey
    def initialize(apikey, pin = nil, language = 'en')
      @language = language
      body = { "apikey" => apikey }
      body["pin"] = pin unless pin.nil? || pin.to_s.empty?
      thetvdb = self.class.post('/login', :body => body.to_json)
      @token = thetvdb.dig('data', 'token')
    end

    #基于电视剧名称获取thetvdb v4的查询结果
    def search(series_name)
      response = self.get("/search?query=#{URI.encode_www_form_component(series_name)}&type=series")
      normalize_results(response)
    end

    #基于imdbid获取thetvdb v4的查询结果(remote_id 形如 imdb-tt1796960)
    def search_by_imdb(imdb_id)
      response = self.get("/search?remote_id=#{RemoteId.for_imdb(imdb_id)}&type=series")
      normalize_results(response)
    end

    #基于电视剧id获取电视剧详细信息
    def get_series_by_id(series_id, language = self.language)
      response = self.get("/series/#{series_id}/extended")
      if response && response["data"]
        Series.new(self, response["data"])
      else
        nil
      end
    end

    #基于电视剧集id获取每集的详细信息
    def get_episode_by_id(episode_id, language = self.language)
      response = self.get("/episodes/#{episode_id}/extended")
      if response && response["data"]
        Episode.new(self, response["data"])
      else
        nil
      end
    end

    #基于季数、集数获取集的详细信息(season_type: default/official/alternate/regional)
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

    #获取演员(v4 在 series extended 的 characters 中返回)
    def get_actors(series)
      characters = series_data(series)["characters"]
      return [] unless characters.is_a?(Array)
      characters.collect { |c| Actor.new(c) }
    end

    # 获取季数
    def get_seasons(series)
      seasons = series_data(series)["seasons"]
      return [] unless seasons.is_a?(Array)
      seasons.map { |s| s.is_a?(Hash) ? s["number"] : s }
    end

    #获取海报、横幅等图片(v4 通过 /series/{id}/artworks,type 为整数 id)
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

    def get(url)
      return self.class.get(url,
                     :headers => {"Authorization" => 'Bearer ' + @token,"Accept-Language" => self.language}).parsed_response
    end

    private

    # v4 经典图片类型 id(完整列表见 /artwork/types)
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

    def series_data(series)
      raw = series.raw if series.respond_to?(:raw)
      return raw if raw.is_a?(Hash) && !raw.empty?
      response = self.get("/series/#{series.id}/extended")
      (response && response["data"]) || {}
    end
  end
end
