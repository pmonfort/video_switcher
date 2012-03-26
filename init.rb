require "sequel"

config_file 'settings.yml'

configure do
  DB = Sequel.connect(
    :adapter  => settings.db[:adapter],
    :user     => settings.db[:username],
    :host     => settings.db[:host],
    :database => settings.db[:db_name],
    :password => settings.db[:password]
  )

  DB.create_table? :video do
    primary_key :id
    String :title
    String :video_original
    String :video_mp4
    String :video_ogg
    String :video_webm
    String :video_thumbnail
  end

  DB.create_table? :region do
    primary_key :id
    String :country_name
    String :country_code
    Integer :start_ip
    Integer :end_ip
    Integer :video_id
  end
end

# require models
Dir.glob(File.join(File.dirname(__FILE__), 'models/*.rb')).each {|f| require f }

