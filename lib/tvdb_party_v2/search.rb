module TvdbPartyV2

  class Search
    include HTTParty
    base_uri 'https://api.thetvdb.com'
    headers "Content-Type" => "application/json"
    attr_accessor :token, :language

    def initialize(apikey, username, userkey, language = 'en', cache_options = {})
      @language = language
      thetvdb = self.class.post('/login',
                                :body => {"apikey" => apikey,
                                          "username" => username,
                                          "userkey" => userkey}.to_json)
      @token = thetvdb['token']
    end

    #基于电视剧英文名称获取thetvdb的查询结果
    def search(series_name)
      response = self.get("/search/series?name=#{URI::encode(series_name)}")
      return [] unless response["data"]
      case response["data"]
      when Array
        response["data"]
      when Hash
        [response["data"]]
      else
        []
      end
    end

    #基于imdbid获取thetvdb的查询结果
    def search_by_imdb(imdb_id)
      response = self.get("/search/series?imdbId=#{imdb_id}")
      return [] unless response["data"]

      case response["data"]
      when Array
        response["data"]
      when Hash
        [response["data"]]
      else
        []
      end
    end

    #基于电视剧id获取电视剧详细信息
    def get_series_by_id(series_id, language = self.language)
      response = self.get("/series/#{series_id.to_s}")
      if response["data"]
        Series.new(self, response["data"])
      else
        nil
      end
    end

    #基于电视剧集id获取每集的详细信息
    def get_episode_by_id(episode_id, language = self.language)
      response = self.get("/episodes/#{episode_id.to_s}")
      if response["data"]
        Episode.new(self, response["data"])
      else
        nil
      end
    end

    #基于季数、集数获取集的详细信息
    def get_episode(series, season_number, episode_number = nil,  page_id = nil)
      if episode_number
        url = "/series/#{series.id}/episodes/query?airedSeason=#{season_number}&airedEpisode=#{episode_number}"
      else
        url = "/series/#{series.id}/episodes/query?airedSeason=#{season_number}"
      end
      url = url + "&page=#{page_id}" unless page_id.nil?

      response = self.get(url)
      return [] unless response["data"]
      if response['links']['next'].nil?
        data = response["data"]
      else
        data << response["data"]
        get_episode(series, season_number, episode_number, self.language, response['links']['next'])
      end
      data.map {|e| self.get_episode_by_id(e["id"])}
    end


    def get_all_episodes(series, page_id = 1)
      if page_id == 1
        url = "/series/#{series.id}/episodes"
      else
        pp url = "/series/#{series.id}/episodes?page=#{page_id}"
      end
      response = self.get(url)
      if response['links']['next'].nil?
        data = response["data"]
      else
        data << response["data"]
        get_all_episodes(series, self.language, response['links']['next'].to_s)
      end

      return [] unless data
      data.select! {|d| d["airedSeason"] > 0} #去除特殊季部分。
      data.map {|e| self.get_episode_by_id(e["id"])}

    end

    def get_actors(series)
      response = self.get("/series/#{series.id}/actors")
      if response["data"]
        response["data"].collect {|a| Actor.new(a)}
      else
        nil
      end
    end

    # 获取季数
    def get_seasons(series)
      response = self.get("/series/#{series.id}/episodes/summary")
      if response["data"] && response["data"]["airedSeasons"]
        return response["data"]["airedSeasons"]
      else
        return []
      end
    end

    def get_banners(series, keyType, subKey = nil)
      if subKey
        url = "/series/#{series.id}/images/query?keyType=#{keyType}&subKey=#{subKey}"
      else
        url = "/series/#{series.id}/images/query?keyType=#{keyType}"
      end
      response = self.get(url)
      return [] unless response["data"]
      case response["data"]
      when Array
        response["data"].map {|result| Banner.new(result)}
      when Hash
        [Banner.new(response["data"])]
      else
        []
      end
    end

    def get(url)
      return self.class.get(url,
                     :headers => {"Authorization" => 'Bearer ' + @token,"Accept-Language" => self.language}).parsed_response
    end
  end
end
