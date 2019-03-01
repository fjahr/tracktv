module Tracktv
  class RecordingFile
    attr_accessor :path, :name, :type

    def initialize(path)
      @path = path
      @name = path.split('/').last.split('.').first
      @type = path.split('.').last
    end

    def file
      File.open(@file_path)
    end
  end
end
