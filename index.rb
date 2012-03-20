require "rubygems"
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/config_file'
require 'haml'

require "./init.rb"
require "./admin"

get '/' do
  #ip integer id, string ip_from, string ip_to, string country, string video
  @video = Country.filter('ip_from <= ? AND ip_to >= ?', request.ip, request.ip).first
  @base_url = Country::VIDEO_BASE_URL
  haml :index
end
