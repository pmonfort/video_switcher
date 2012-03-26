require 'rubygems'
require 'sequel'
require 'digest'

class Video < Sequel::Model
  one_to_many :region

  VIDEO_BASE_PATH = 'public/videos/'
  VIDEO_BASE_URL = 'videos/'
  plugin :validation_helpers
  def validate
    super

    Sequel::Plugins::ValidationHelpers::DEFAULT_OPTIONS.merge!(:presence=>{:message=>'cannot be empty'})

    if self.default
      validates_unique [:title]
      validates_presence [:title]
      if self.country_code
        validates_unique [:country_code]
      end
    else
      validates_unique [:title]
      validates_unique [:country_code]
      validates_presence [:title, :country_code]
    end

  end

  def video=(video_path)
    begin
      process_video(video_path)
    rescue => e
      #TODO
      self.errors.add(:video, 'no valid')
      raise "Invalid Video"
    end
  end

  private

  def check_fs_permission(path)
    File.readable?(path) && File.writable?(VIDEO_BASE_PATH)
  end

  def process_video(input_path)

    raise "Permission exceptions" unless check_fs_permission(input_path)

    file_name = Digest::MD5.hexdigest(Time.now.to_s + self.country_code)
    copy_original_file(file_name, input_path)
    convert_video(file_name, ".mp4")
    convert_video(file_name, ".ogg")
    convert_video(file_name, ".webm")
    create_video_thumbnail(file_name)
  end

  def copy_original_file(file_name, input_path)
    output_path = file_name + "_ORIGINAL"
    input = File.open(input_path, 'r')
    output = File.new(VIDEO_BASE_PATH + output_path, "w+")
    output.write(input.read)
    output.close
    self.video_original = output_path
  end

  def convert_video(file_name, extension)
    output_path = file_name + extension
    command = "ffmpeg -i %s -target ntsc-vcd %s" % [VIDEO_BASE_PATH + self.video_original, VIDEO_BASE_PATH + output_path]

    case extension
      when ".mp4"
        self.video_mp4 = output_path
      when ".ogg"
        command = "ffmpeg2theora %s -o %s" % [VIDEO_BASE_PATH + self.video_original, VIDEO_BASE_PATH + output_path]
        self.video_ogg = output_path
      when ".webm"
        self.video_webm = output_path
      else
        raise "Invalid extension error"
    end

    output = `#{command}`
    raise "FFMPEG unknowkn error" unless output
  end

  def create_video_thumbnail(file_name, resolution = "64x64", frame = "10")
    output_path = file_name + ".jpg"
    command = "ffmpeg -i %s -vcodec mjpeg -vframes 10 -an -f rawvideo -s 64x64 %s" % [VIDEO_BASE_PATH + self.video_original, VIDEO_BASE_PATH + output_path]
    output = `#{command}`
    raise "FFMPEG creating thumbnail error" unless output
    self.video_thumbnail = VIDEO_BASE_URL + output_path
  end
end
