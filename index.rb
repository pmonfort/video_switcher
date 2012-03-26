require "rubygems"
require "sequel"
require 'haml'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/content_for'
require 'geokit'

module VideoSwitcher
  class Public < Sinatra::Base
    register Sinatra::ConfigFile
    config_file 'settings.yml'

    helpers Sinatra::ContentFor

    configure do
      DB = Sequel.connect(
        :adapter  => settings.db[:adapter],
        :user     => settings.db[:username],
        :host     => settings.db[:host],
        :database => settings.db[:db_name],
        :password => settings.db[:password]
      )
      DB.create_table? :videos do
        primary_key :id
        String :title
        String :country_code
        Boolean :default
        String :video_original
        String :video_mp4
        String :video_ogg
        String :video_webm
        String :video_thumbnail
      end
    end

    get '/' do
      ip = "12.215.42.19"
      #location = Geokit::Geocoders::IpGeocoder.geocode(request.ip)
      location = Geokit::Geocoders::IpGeocoder.geocode(ip)
      @video = Video.filter(:country_code => location.country_code).first unless !location.country_code
      @video = Video.filter(:default => true).first unless @video
      @height = settings.video[:height]
      @width = settings.video[:width]
      @base_url = Video::VIDEO_BASE_URL
      haml :index
    end
  end

  class Admin < Sinatra::Base
    register Sinatra::ConfigFile
    config_file 'settings.yml'

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
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.admin[:username], settings.admin[:password]]
      end
    end

    get '/' do
      protected!
      @videos = Video.all
      @base_url = Video::VIDEO_BASE_URL
      haml :'admin/videos/index'
    end

    # ---- Videos ----

    get '/videos' do
      protected!
      @videos = Video.all
      @base_url = Video::VIDEO_BASE_URL
      haml :'admin/videos/index'
    end

    get '/videos/add' do
      protected!
      @video = Video.new
      @actionUrl = "/admin/videos/add"
      haml :'admin/videos/add'
    end

    post '/videos/add' do
      protected!
      @video = Video.new
      @video.title = params[:title]
      @video.country_code = params[:country_code]
      @video.default = params[:default]
      begin
        raise 'Invalid model' unless @video.valid?
        if !params[:video]
          @video.errors.add(:video, 'cannot be empty')
          raise 'Invalid video'
        end
        @video.video = params[:video][:tempfile].path
        @video.save
        redirect '/admin'
      rescue => e

        require "ruby-debug"; debugger; ""
        @errors = @video.errors
        haml :'admin/videos/add'
      end
    end

    get '/videos/:id' do
      protected!
      @video = Video[:id => params[:id]]
      if @video.nil?
        haml :'404'
      end
      @base_url = Video::VIDEO_BASE_URL
      @actionUrl = "/admin/videos/" + @video[:id].to_s
      haml :'admin/videos/edit'
    end

    post '/videos/:id' do
      protected!
      @video = Video[:id => params[:id]]
      @video.title = params[:title]
      @video.country_code = params[:country_code]
      @video.default = params[:default]
      begin
        raise 'Invalid model' unless @video.valid?
        @video.video = params[:video][:tempfile].path if params[:video]
        @video.save
        redirect '/admin'
      rescue => e
        @errors = @video.errors
        haml :'admin/videos/add'
      end
    end

    get '/videos/:id/delete' do
      protected!
      @video = Video[:id => params[:id]]
      @video.destroy
      redirect '/admin'
    end
  end

  require_relative 'models/video'
end
