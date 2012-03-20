require 'init.rb'
require "./models/country"
require "./admin"

get '/' do
  #ip integer id, string ip_from, string ip_to, string country, string video
  #ip = DB["SELECT * FROM ip WHERE ip_from <= ? AND ip_to >= ? LIMIT 1", request.ip, request.ip]
  #ip = DB["SELECT * FROM ip WHERE ip_from <= ? AND ip_to >= ? LIMIT 1", '186.48.5.106', '186.48.5.106']
  #@video = "assets/" + ip.map(:video).first
  @video = Country.filter('ip_from <= ? AND ip_to >= ?', '186.88.4.100', '186.88.4.100').first

  require "ruby-debug"; debugger; ""
  @base_url = Country::VIDEO_BASE_URL
  haml :index
end
