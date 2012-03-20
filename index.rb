require "rubygems"
require 'haml'
require "sequel"
require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/config_file'

module VideoSwitcher
  class Public < Sinatra::Base
    register Sinatra::ConfigFile
    config_file 'settings.yml'

    helpers Sinatra::ContentFor

    configure do
      DB = Sequel.connect(
        :adapter  => settings.db[:adapter],
        :user     => settings.db[:user],
        :host     => settings.db[:host],
        :database => settings.db[:db_name],
        :password => settings.db[:password]
      )

      DB.create_table? :countries do
        primary_key :id
        String :ip_from
        String :ip_to
        String :country
        String :video_original
        String :video_mp4
        String :video_ogg
        String :video_webm
        String :video_thumbnail
      end
    end

    get '/' do
      #ip integer id, string ip_from, string ip_to, string country, string video
      @video = Country.filter('ip_from <= ? AND ip_to >= ?', request.ip, request.ip).first
      @base_url = Country::VIDEO_BASE_URL
      haml :index
    end
  end

  class Admin < Sinatra::Base
    USER = "admin"
    PASSWORD = "admin"

    helpers Sinatra::ContentFor

    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [USER, PASSWORD]
      end
    end

    get '/' do
      protected!
      @countries = Country.all
      @base_url = Country::VIDEO_BASE_URL
      haml :'admin/countries/index'
    end

    get '/countries/add' do
      protected!
      @country = Country.new
      @actionUrl = "/admin/countries/add"
      haml :'admin/countries/add'
    end

    post '/countries/add' do
      protected!
      @country = Country.new
      @country.ip_from = params[:ip_from]
      @country.ip_to = params[:ip_to]
      @country.country = params[:country]
      @country.video = params[:video][:tempfile].path if params[:video]
      begin
        raise 'Invalid model' unless @country.valid?
        @country.save
        redirect '/admin'
      rescue => e
        @errors = @country.errors
        haml :'admin/countries/add'
      end
    end

    get '/countries/:id' do
      protected!
      @country = Country[:id => params[:id]]
      if @country.nil?
        haml :'404'
      end
      @base_url = Country::VIDEO_BASE_URL
      @actionUrl = "/admin/countries/" + @country[:id].to_s
      haml :'admin/countries/country'
    end

    post '/countries/:id' do
      protected!
      @country = Country[:id => params[:id]]
      @country.ip_from = params[:ip_from]
      @country.ip_to = params[:ip_to]
      @country.country = params[:country]
      @country.video = params[:video][:tempfile].path unless params[:video].nil?
      begin
        raise 'Invalid model' unless @country.valid?
        @country.save
        redirect '/admin'
      rescue => e
        @errors = @country.errors
        haml :'admin/countries/add'
      end
    end

    get '/countries/:id/delete' do
      protected!
      @country = Country[:id => params[:id]]
      @country.destroy
      redirect '/admin'
    end
  end

  require_relative 'models/country'
end
