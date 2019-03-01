module Tracktv
  class Comskip

    def self.find_breaks(file_path)
      p "==================== Searching Commercial Breaks in #{file_path} ===================="
      command = "wine ./programs/comskip81_063/comskip.exe #{file_path}"
      breaks = []
      system command
      edl_path = file_path.gsub('.mpg', '.edl')
      File.open(edl_path).each do |line|
        splitted_line = line.split(' ')
        breaks << [splitted_line[0], splitted_line[1]]
      end
      breaks
    end

    def self.find_all_commercials(break_file_paths)
      commercials_by_file = {}

      break_file_paths.each do |break_file|
        commercials_by_file[break_file] = []
      end

      break_file_paths.each do |break_file|
        commercials = find_commercials(break_file)
        commercials_by_file[break_file] << commercials
      end

      commercials_by_file
    end

    def self.find_commercials(file_path)
      p "==================== Searching individual Commercials in #{file_path} ===================="
      command = "wine ./programs/comskip81_063/comskip.exe #{file_path}"
      @commercials = []
      system command
      log_path = file_path.gsub('.mpg', '.log')
      File.open(log_path).each_with_index do |line, index|
        splitted_line = line.split(' ')
        if splitted_line[0] == "Framerate:"
          @frame_rate = splitted_line[1].to_f
        end
        if splitted_line[0] == "#"
          @start_line = index
        end
        if @start_line && index > @start_line
          if splitted_line[0] && splitted_line[0].include?(':')
            @commercials << [splitted_line[4].to_f/@frame_rate, splitted_line[5].to_f/@frame_rate]
          else
            break
          end
        end
      end
      @commercials
    end
  end
end
