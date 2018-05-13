require 'minitest/autorun'
require 'tvdb_party_v2'


class TvdbPartyV2Test < Minitest::Test
  def setup
    @thetvdb = TvdbPartyV2::Search.new("","","") # pls add apikey,username,userkey,
  end

  def test_terrible_query_search
    assert_empty @results = @thetvdb.search("sdfsafsdfds"), "query terrible query search."
  end

  def test_not_exist_episode
    @results = @thetvdb.get_series_by_id(247897) #homeland thetvdb
    assert_empty @results.episode(1,20), "have handle 404 on episode query"
  end

  def test_search_show
    @results = @thetvdb.search('Homeland')
    assert_equal "Homeland",@results.first["seriesName"],"search homeland show."
  end

  def test_get_series
    @series = @thetvdb.get_series_by_id(247897) #homeland series id
    assert_equal TvdbPartyV2::Series, @series.class ,"have a series"
  end

  def test_have_actors
    @series = @thetvdb.get_series_by_id(247897) #homeland series id
    assert_equal true,@series.actors.size > 0,"have actual Actors"
  end

  def test_first_episode
    @series = @thetvdb.get_series_by_id(247897) #homeland series id
    assert_equal 4079947,@series.episode(1,1).first.id,"homeland first episode"
  end

  def test_have_season
    @series = @thetvdb.get_series_by_id(247897) #homeland series id
    assert_equal true,@series.seasons.size > 0 , "homeland have seasons"
  end

  def test_imdb_search
    @series = @thetvdb.search_by_imdb('tt1796960') #homeland imdb_id search
    assert_equal "Homeland",@series.first["seriesName"]
  end

  def test_not_english_search
    @thetvdb = TvdbPartyV2::Search.new("","","",'zh')
    assert_equal true,@thetvdb.search("国土安全").size > 0,"search homeland chinese name"
  end

end
