module Tracktv
  class FFMPEG

    def self.mkv_to_mpeg2(file)
      p "==================== Converting #{file.name} to mpeg2 ===================="
      command = "ffmpeg -i \"#{file.path}\" -vcodec mpeg2video -acodec copy -f vob -copyts -y \"./temp/#{file.name}.mpg\" "
      if system command
        "./temp/#{file.name}.mpg"
      end
    end

    def self.extract_breaks(file_path, breaks)
      extracted_file_paths = []

      breaks.each_with_index do |times, index|
        break_file_path = file_path.gsub(".mpg", "-break-#{index}.mpg")
        extracted_file_paths << break_file_path
        command = "ffmpeg -i #{file_path} -ss #{times[0]} -t #{times[1].to_f - times[0].to_f} #{break_file_path}"
        system command
      end

      extracted_file_paths
    end

    def self.extract_commercials(files_with_break_points)
      commercial_file_paths = []
      file_paths = files_with_break_points.keys

      file_paths.each do |file_path|
        break_points = files_with_break_points[file_path][0]

        break_points.each_with_index do |break_point, index|
          commercial_file_path = file_path.gsub(".mpg", "-com-#{index}.mpg")
          command = "ffmpeg -i #{file_path} -ss #{break_point[0]} -t #{break_point[1].to_f - break_point[0].to_f} #{commercial_file_path}"
          system command
          commercial_file_paths << commercial_file_path
        end
      end
      commercial_file_paths
    end

    def self.mpeg_to_wav(all_mpeg_commercials)
      all_wav_commercials = []

      all_mpeg_commercials.each do |mpeg_file|
        wav_file = mpeg_file.gsub('.mpg', '.wav')
        command = "ffmpeg -i #{mpeg_file} -acodec pcm_s16le -ac 2 #{wav_file}"
        system command
        all_wav_commercials << wav_file
      end

      all_wav_commercials
    end
  end
end
