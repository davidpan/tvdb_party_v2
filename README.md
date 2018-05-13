# TvdbPartyV2

[![Gem Version](https://badge.fury.io/rb/tvdb_party_v2.svg)](https://badge.fury.io/rb/tvdb_party_v2)

Simple Ruby library to talk to thetvdb.com API v2

# what is thetvdb.com?

This site is an open tvshow database that can be modified by anybody.
thetvdb.com api v2.1.2 (https://api.thetvdb.com/swagger)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tvdb_party_v2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tvdb_party_v2

## Usage


```ruby
# connect api
@thetvdb = TvdbPartyV2::Search.new(apikey,username,userkey)

# search tv show
r = @thetvdb.search("Homeland")

# get series
puts homeland = @thetvdb.get_series_by_id(r.first["id"])

# get episode
puts s01e01 = homeland.get_episode(1,1)

#get series fanart – pass in your language
puts homeland.fanart.first.url
=> "https://www.thetvdb.com/banners/fanart/original/247897-18.jpg"

#get series posters
puts homeland.posters.first.url
=> "https://www.thetvdb.com/banners/seasons/247897-1.jpg"

#get series banners
puts homeland.series_banners.first.url
=> "https://www.thetvdb.com/banners/graphical/247897-g.jpg"

#get season posters
puts homeland.season_posters(2).first.url
=> "https://www.thetvdb.com/banners/seasons/247897-2.jpg"

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidpan/tvdb_party_v2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TvdbPartyV2 project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tvdb_party_v2/blob/master/CODE_OF_CONDUCT.md).

## Thanks

Project Derived from maddox/tvdb_party.

Thanks to thetvdb.com for their awesome database allowing us to meta out to our hearts consent.
Project name graciously stolen from jduff/tmdb_party.
