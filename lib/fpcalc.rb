module Tracktv
  class FPCalc
    def self.get_all_fingerprints(all_wav_file_paths)
      all_wav_file_paths.each do |file_path|
        command = "./programs/chromaprint-fpcalc-1.1-osx-x86_64/fpcalc -raw #{file_path} >> ./temp/results.txt"
        system command
      end
      command
    end

  end
end
