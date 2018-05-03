require "tvdb_party_v2/version"
require 'rubygems'
require 'httparty'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'tvdb_party_v2', 'search')
require File.join(directory, 'tvdb_party_v2', 'series')
require File.join(directory, 'tvdb_party_v2', 'episode')
require File.join(directory, 'tvdb_party_v2', 'banner')
require File.join(directory, 'tvdb_party_v2', 'actor')
