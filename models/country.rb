require 'rubygems'
require 'sequel'

DBUSER = 'root'
DBPASSWORD = '3578'
VIDEO_BASE_PATH = "public/videos/"

DB = Sequel.connect(:adapter => 'mysql2', :user => DBUSER, :host => 'localhost', :database => 'qr',:password => DBPASSWORD)

# create an items table
DB.create_table? :countries do
  primary_key :id
  String :ip_from
  String :ip_to
  String :country
  String :video_original
  String :video_mp4
  String :video_ogg
end

class Country < Sequel::Model
  def video=(video_path)
    begin
      process_video(video_path)
    rescue => e
      #TODO
    end
  end

  private

  def check_fs_permission(path)
    File.readable?(path) && File.writable?(VIDEO_BASE_PATH)
  end

  def process_video(input_path)
    return unless check_fs_permission(input_path)

    base_path = VIDEO_BASE_PATH + self.ip_from + "%s"
    mp4_path = base_path % ".mp4"
    ogg_path = base_path % ".ogg"

    command_str = "ffmpeg -i #{input_path} -target ntsc-vcd %s"
    mp4_command = command_str % mp4_path
    ogg_command = command_str % ogg_path

    out = system(mp4_command)
    raise "FFMPEG unknowkn error" unless out
    system(ogg_command)

    self.video_mp4 = mp4_path
    self.video_ogg = ogg_path

    copy_original_file(input_path)
  end

  def copy_original_file(input_path)
    path = VIDEO_BASE_PATH + self.ip_from + "_ORIGINAL"
    input = File.open(input_path, 'r')
    output = File.new(path, "w+")
    output.write(input.read)
    output.close
    self.video_original = path
  end
end
