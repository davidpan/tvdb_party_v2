require 'minitest/autorun'
require 'webmock/minitest'
require 'tvdb_party_v2'

WebMock.disable_net_connect!

# 无凭据的 mock 集成测试:所有 HTTP 交互均由 WebMock 桩替
# 样例响应依据 thetvdb v4 API (https://thetvdb.github.io/v4-api/) 官方 schema 构造
class TvdbPartyV2Test < Minitest::Test
  BASE = 'https://api4.thetvdb.com/v4'

  SEARCH_RESULT = {
    "id" => "247897",
    "name" => "Homeland",
    "overview" => "A bipolar CIA operative is convinced a prisoner of war has been turned.",
    "image_url" => "https://www.thetvdb.com/banners/posters/247897-1.jpg",
    "first_air_time" => "2011-10-02",
    "network" => "Showtime",
    "status" => "Continuing",
    "genres" => ["Drama"]
  }.freeze

  SERIES_EXTENDED = {
    "id" => 247897,
    "name" => "Homeland",
    "overview" => "A bipolar CIA operative is convinced a prisoner of war has been turned.",
    "firstAired" => "2011-10-02",
    "averageRuntime" => 55,
    "score" => 8.5,
    "originalNetwork" => { "id" => 20, "name" => "Showtime" },
    "status" => { "id" => 1, "name" => "Continuing" },
    "genres" => [{ "id" => 18, "name" => "Drama" }],
    "remoteIds" => [{ "id" => "tt1796960", "type" => 3, "sourceName" => "IMDb" }],
    "characters" => [
      { "id" => 1, "name" => "Carrie Mathison", "personName" => "Claire Danes",
        "peopleId" => 1001, "personImgURL" => "actor/1001.jpg",
        "peopleType" => { "id" => 2, "name" => "Actor" }, "sort" => 1 },
      { "id" => 2, "name" => "Nicholas Brody", "personName" => "Damian Lewis",
        "peopleId" => 1002, "personImgURL" => "actor/1002.jpg",
        "peopleType" => { "id" => 2, "name" => "Actor" }, "sort" => 2 }
    ],
    "seasons" => [
      { "id" => 46249, "number" => 1, "seriesId" => 247897 },
      { "id" => 46250, "number" => 2, "seriesId" => 247897 }
    ]
  }.freeze

  EPISODE_EXTENDED = {
    "id" => 4079947,
    "seriesId" => 247897,
    "seasonNumber" => 1,
    "number" => 1,
    "name" => "Pilot",
    "aired" => "2011-10-02",
    "overview" => "CIA officer Carrie Mathison trusts only her instincts.",
    "image" => "episodes/247897/4079947.jpg",
    "score" => 8.9,
    "remoteIds" => [{ "id" => "tt1971493", "type" => 3, "sourceName" => "IMDb" }],
    "seasons" => [{ "id" => 46249, "number" => 1 }],
    "characters" => [
      { "id" => 3, "name" => "Lynne", "personName" => "Some Guest",
        "peopleId" => 1003, "peopleType" => { "id" => 4, "name" => "Guest Star" } }
    ]
  }.freeze

  def setup
    stub_request(:post, "#{BASE}/login")
      .with(body: hash_including("apikey" => "KEY"))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: JSON.dump({ "status" => "success", "data" => { "token" => "TESTTOKEN" } })
      )
    @thetvdb = TvdbPartyV2::Search.new("KEY")
  end

  def test_login_token
    assert_equal "TESTTOKEN", @thetvdb.token
  end

  def test_login_with_pin
    stub_request(:post, "#{BASE}/login")
      .with(body: hash_including("apikey" => "KEY", "pin" => "1234"))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: JSON.dump({ "status" => "success", "data" => { "token" => "PINTOKEN" } })
      )
    client = TvdbPartyV2::Search.new("KEY", "1234")
    assert_equal "PINTOKEN", client.token
  end

  def test_terrible_query_search
    stub_request(:get, "#{BASE}/search")
      .with(query: hash_including("type" => "series"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => nil }))
    assert_empty @results = @thetvdb.search("sdfsafsdfds"), "query terrible query search."
  end

  def test_search_show
    stub_request(:get, "#{BASE}/search")
      .with(query: hash_including("type" => "series", "query" => "Homeland"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => [SEARCH_RESULT] }))
    @results = @thetvdb.search('Homeland')
    assert_equal "Homeland", @results.first["name"], "search homeland show."
  end

  def test_imdb_search
    stub_request(:get, "#{BASE}/search")
      .with(query: hash_including("type" => "series", "remote_id" => "imdb-tt1796960"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => [SEARCH_RESULT] }))
    @results = @thetvdb.search_by_imdb('tt1796960') # homeland imdb_id search
    assert_equal "Homeland", @results.first["name"]
    assert_requested :get, "#{BASE}/search", query: hash_including("remote_id" => "imdb-tt1796960")
  end

  def test_not_english_search
    stub_request(:get, "#{BASE}/search")
      .with(query: hash_including("type" => "series", "query" => "国土安全"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => [SEARCH_RESULT] }))
    @thetvdb = TvdbPartyV2::Search.new("KEY", nil, 'zh')
    assert_equal true, @thetvdb.search("国土安全").size > 0, "search homeland chinese name"
  end

  def test_get_series
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    @series = @thetvdb.get_series_by_id(247897) #homeland series id
    assert_equal TvdbPartyV2::Series, @series.class, "have a series"
    assert_equal "Homeland", @series.name
    assert_equal "tt1796960", @series.imdb_id
    assert_equal 8.5, @series.rating
    assert_equal "Continuing", @series.status
    assert_equal "Showtime", @series.network
    assert_equal ["Drama"], @series.genres
    assert_equal true, @series.first_aired > 0, "first_aired parsed (require 'time' fix)"
  end

  def test_have_actors
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    @series = @thetvdb.get_series_by_id(247897)
    assert_equal true, @series.actors.size > 0, "have actual Actors"
    assert_equal "Claire Danes", @series.actors.first.name
    assert_equal "Carrie Mathison", @series.actors.first.role
  end

  def test_have_season
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    @series = @thetvdb.get_series_by_id(247897)
    assert_equal true, @series.seasons.size > 0, "homeland have seasons"
    assert_equal 1, @series.seasons.first
  end

  def test_first_episode
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    stub_request(:get, "#{BASE}/series/247897/episodes/default")
      .with(query: hash_including("season" => "1", "episodeNumber" => "1"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success",
                                   "data" => { "episodes" => [{ "id" => 4079947 }] } }))
    stub_request(:get, "#{BASE}/episodes/4079947/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => EPISODE_EXTENDED }))
    @series = @thetvdb.get_series_by_id(247897) #homeland series id
    episode = @series.episode(1, 1).first
    assert_equal 4079947, episode.id, "homeland first episode"
    assert_equal 1, episode.season_number
    assert_equal 1, episode.number
    assert_equal "Pilot", episode.name
    assert_equal true, episode.air_date > 0, "air_date parsed (require 'time' fix)"
    assert_equal "https://www.thetvdb.com/banners/episodes/247897/4079947.jpg", episode.thumb
    assert_equal ["Some Guest"], episode.guest_stars
  end

  def test_not_exist_episode
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    stub_request(:get, "#{BASE}/series/247897/episodes/default")
      .with(query: hash_including("season" => "1", "episodeNumber" => "20"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => { "episodes" => [] } }))
    @results = @thetvdb.get_series_by_id(247897) #homeland thetvdb
    assert_empty @results.episode(1, 20), "have handle 404 on episode query"
  end

  def test_episode_pagination
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    stub_request(:get, "#{BASE}/series/247897/episodes/default")
      .with(query: hash_including("season" => "1"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success",
                                   "data" => { "episodes" => [{ "id" => 4079947 }] },
                                   "links" => { "next" => 2 } }))
      .then.to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                      body: JSON.dump({ "status" => "success",
                                        "data" => { "episodes" => [{ "id" => 4079948 }] } }))
    stub_request(:get, "#{BASE}/episodes/4079947/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => EPISODE_EXTENDED }))
    stub_request(:get, "#{BASE}/episodes/4079948/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success",
                                   "data" => { "id" => 4079948, "seasonNumber" => 1, "number" => 2, "name" => "Grace" } }))
    @series = @thetvdb.get_series_by_id(247897)
    episodes = @series.season(1)
    assert_equal 2, episodes.size, "pagination collects both pages"
    assert_equal 4079948, episodes.last.id
  end

  def test_banners
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    artworks = {
      "artworks" => [
        { "id" => 9002, "image" => "posters/247897-2.jpg", "thumbnail" => "posters/247897-2_t.jpg",
          "type" => 2, "score" => 8.0, "width" => 680, "height" => 1000 }
      ],
      "seasons" => SERIES_EXTENDED["seasons"]
    }
    stub_request(:get, %r{/v4/series/247897/artworks})
      .with(query: hash_including("type" => "2"))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => artworks }))
    @series = @thetvdb.get_series_by_id(247897)
    posters = @series.posters
    assert_equal 1, posters.size, "poster type filter (artwork type id 2)"
    assert_equal "https://www.thetvdb.com/banners/posters/247897-2.jpg", posters.first.url
    assert_equal "https://www.thetvdb.com/banners/_cache/posters/247897-2_t.jpg", posters.first.thumb_url
    assert_equal "680x1000", posters.first.banner_resolution
  end

  def test_thumb_url_no_double_cache_prefix
    banner = TvdbPartyV2::Banner.new({ "image" => "posters/x.jpg", "thumbnail" => "_cache/posters/x_t.jpg" })
    assert_equal "https://www.thetvdb.com/banners/_cache/posters/x_t.jpg", banner.thumb_url
  end

  def test_season_posters_by_subkey
    stub_request(:get, "#{BASE}/series/247897/extended")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => SERIES_EXTENDED }))
    artworks = {
      "artworks" => [
        { "id" => 9001, "image" => "seasons/247897-1.jpg", "thumbnail" => "_cache/seasons/247897-1.jpg",
          "type" => 6, "score" => 9.0, "width" => 400, "height" => 578, "seasonId" => 46249 },
        { "id" => 9004, "image" => "seasons/247897-2.jpg", "thumbnail" => "_cache/seasons/247897-2.jpg",
          "type" => 6, "score" => 8.0, "width" => 400, "height" => 578, "seasonId" => 46250 }
      ],
      "seasons" => SERIES_EXTENDED["seasons"]
    }
    stub_request(:get, %r{/v4/series/247897/artworks})
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: JSON.dump({ "status" => "success", "data" => artworks }))
    @series = @thetvdb.get_series_by_id(247897)
    posters = @series.season_posters(1)
    assert_equal 1, posters.size, "season subkey filtered via seasonId mapping"
    assert_equal "1", posters.first.subkey
  end
end
