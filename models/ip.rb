require 'rubygems'
require 'sequel'

DBUSER = 'root'
DBPASSWORD = '3578'
VIDEO_BASE_PATH = "public/videos/"

DB = Sequel.connect(:adapter => 'mysql2', :user => DBUSER, :host => 'localhost', :database => 'qr',:password => DBPASSWORD)

# create an items table
DB.create_table? :ips do
  primary_key :id
  String :ip_from
  String :ip_to
  String :country
  String :video
end

class Ip < Sequel::Model
  def video=(video_path)
    begin
      process_video(video_path)
    rescue => e
      #TODO

      require "ruby-debug"; debugger; ""
    end
  end

  private

  def check_fs_permission(path)
    File.readable?(path) && File.writable?(VIDEO_BASE_PATH)
  end

  def process_video(input_path)
    return unless check_fs_permission(input_path)

    base_path = VIDEO_BASE_PATH + self.ip_from
    command_str = "ffmpeg -i #{input_path} -target ntsc-vcd #{base_path}.%s"

    mp4_command = command_str % "mp4"
    ogg_command = command_str % "ogg"

    out = system(mp4_command)
    raise "FFMPEG unknowkn error" unless out
    system(ogg_command)

    copy_original_file(input_path)
  end

  def copy_original_file(input_path)
    input = File.open(input_path, 'r')
    output = File.new(VIDEO_BASE_PATH + self.ip_from + "_ORIGINAL", "w+")
    output.write(input.read)
    output.close
  end
end
