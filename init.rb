require "sequel"

config_file 'settings.yml'

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

# require models
Dir.glob(File.join(File.dirname(__FILE__), 'models/*.rb')).each {|f| require f }

