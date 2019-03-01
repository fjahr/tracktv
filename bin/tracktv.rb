#!/usr/bin/env ruby

require_relative '../lib/recording_file'
require_relative '../lib/ffmpeg'
require_relative '../lib/comskip'
require_relative '../lib/fpcalc'

def run!
  recording_file_path = ARGV[0]
  recording = Tracktv::RecordingFile.new(recording_file_path)
  mpg_file_path = Tracktv::FFMPEG.mkv_to_mpeg2(recording)
  breaks = Tracktv::Comskip.find_breaks(mpg_file_path)
  break_video_file_paths = Tracktv::FFMPEG.extract_breaks(mpg_file_path, breaks)
  commercial_break_points_per_break = Tracktv::Comskip.find_all_commercials(break_video_file_paths)
  all_commercials_per_break = Tracktv::FFMPEG.extract_commercials(commercial_break_points_per_break)

  all_commercial_wavs = Tracktv::FFMPEG.mpeg_to_wav(all_commercials_per_break)
  all_fingerprints = Tracktv::FPCalc.get_all_fingerprints(all_commercial_wavs)
  Tracktv::PGConnector.insert_all(all_fingerprints)

end

run!

