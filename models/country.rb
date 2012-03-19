require 'rubygems'
require 'sequel'

DBUSER = 'root'
DBPASSWORD = '3578'

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
  String :video_webm
  String :video_thumbnail
end

class Country < Sequel::Model
  VIDEO_BASE_PATH = "public/videos/"
  VIDEO_BASE_URL = "videos/"

  def video=(video_path)
    begin
      process_video(video_path)
    rescue => e
      #TODO
      self.video_ogg = ''
      self.video_mp4 = ''
      self.video_original = ''
      self.video_thumbnail = ''
      require "ruby-debug"; debugger; ""
    end
  end

  private

  def check_fs_permission(path)
    File.readable?(path) && File.writable?(VIDEO_BASE_PATH)
  end

  def process_video(input_path)
    return unless check_fs_permission(input_path)

    copy_original_file(input_path)

    require "ruby-debug"; debugger; ""
    convert_video(".mp4")
    convert_video(".ogg")
    convert_video(".webm")
    create_video_thumbnail()
  end

  def copy_original_file(input_path)
    output_path = self.ip_from + "_ORIGINAL"
    input = File.open(input_path, 'r')
    output = File.new(VIDEO_BASE_PATH + output_path, "w+")
    output.write(input.read)
    output.close
    self.video_original = output_path
  end

  def convert_video(extension)
    output_path = self.ip_from + extension
    command = "ffmpeg -i %s -target ntsc-vcd %s" % [VIDEO_BASE_PATH + self.video_original, VIDEO_BASE_PATH + output_path]

    case extension
      when ".mp4"
        self.video_mp4 = output_path
      when ".ogg"
        command = "ffmpeg2theora %s -o %s" % [VIDEO_BASE_PATH + self.video_original, VIDEO_BASE_PATH + output_path]
        self.video_ogg = output_path
        require "ruby-debug"; debugger; ""
      when ".webm"
        self.video_webm = output_path
      else
        raise "Invalid extension error"
    end

    output = `#{command}`
    raise "FFMPEG unknowkn error" unless output
  end

  def create_video_thumbnail(resolution = "64x64", frame = "10")
    output_path = self.ip_from + ".jpg"
    command = "ffmpeg -i %s -vcodec mjpeg -vframes 10 -an -f rawvideo -s 64x64 %s" % [VIDEO_BASE_PATH + self.video_original, VIDEO_BASE_PATH + output_path]
    output = `#{command}`
    raise "FFMPEG creating thumbnail error" unless output
    self.video_thumbnail = output_path
  end
end
