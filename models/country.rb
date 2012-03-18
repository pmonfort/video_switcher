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
  String :video_thumbnail
end

class Country < Sequel::Model
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
    convert_video(input_path, ".mp4")
    convert_video(input_path, ".ogg")
    copy_original_file(input_path)
    create_video_thumbnail(input_path)
  end

  def convert_video(input_path, extension)
    output_path = VIDEO_BASE_PATH + self.ip_from + extension
    command = "ffmpeg -i %s -target ntsc-vcd %s" % [input_path, output_path]
    output = system(command)

    raise "FFMPEG unknowkn error" unless output

    case extension
      when ".mp4"
        self.video_mp4 = output_path
      when ".ogg"
        self.video_ogg = output_path
      else
        raise "Invalid extension error"
    end
  end

  def copy_original_file(input_path)
    path = VIDEO_BASE_PATH + self.ip_from + "_ORIGINAL"
    input = File.open(input_path, 'r')
    output = File.new(path, "w+")
    output.write(input.read)
    output.close
    self.video_original = path
  end

  def create_video_thumbnail(input_path, resolution = "64x64", frame = "10")
    output_path = VIDEO_BASE_PATH + self.ip_from + ".jpg"
    command = "ffmpeg -i %s -vcodec mjpeg -vframes 10 -an -f rawvideo -s 64x64 %s" % [input_path, output_path]
    output = system(command)
    raise "FFMPEG creating thumbnail error" unless output
    self.video_thumbnail = output_path
  end
end
