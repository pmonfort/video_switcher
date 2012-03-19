#gems
require "rubygems"
require "sequel"
require 'sinatra'
require 'sinatra/content_for'

#files
require "./models/country"
require "./admin"

get '/' do
  #ip integer id, string ip_from, string ip_to, string country, string video
  #ip = DB["SELECT * FROM ip WHERE ip_from <= ? AND ip_to >= ? LIMIT 1", request.ip, request.ip]
  #ip = DB["SELECT * FROM ip WHERE ip_from <= ? AND ip_to >= ? LIMIT 1", '186.48.5.106', '186.48.5.106']
  #@video = "assets/" + ip.map(:video).first
  @video = Country.filter('ip_from <= ? AND ip_to >= ?', '186.48.4.100', '186.48.4.100').first
  @base_url = Country::VIDEO_BASE_URL
  haml :index
end
