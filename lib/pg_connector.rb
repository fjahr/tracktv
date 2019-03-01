require 'pg'

module Tracktv
  class PGConnector
    def initialize
      @conn = PG::Connection.open(:dbname => 'tracktv_test')
      @conn.prepare("ins", "INSERT INTO tracktv (ID, NAME, DURATAION, FILE_NAME, FINGERPRINT) VALUES ($1, $2, $3, $4, $5)")
      @conn.prepare("all", "SELECT * FROM tracktv;")
    end

    def setup
      # require './lib/pg_connector'; pg = Tracktv::PGConnector.new
      @conn.exec_params('CREATE TABLE tracktv (ID INT PRIMARY KEY NOT NULL, NAME TEXT, DURATAION INT, FILE_NAME TEXT, FINGERPRINT integer ARRAY);')
    end

    def drop
      @conn.exec_params('DROP TABLE tracktv')
    end

    def match_all(results)
      all_commercials = @conn.exec_prepared("all", [])
      File.open(results).each_with_index do |line, index|
        if line.include?("FINGERPRINT=")
          fingerprint = line.gsub("FINGERPRINT=", "").split(",").map(&:to_i)
          all_commercials.each do |comm|
            db_fps = comm["fingerprint"].gsub("{", "").gsub("}", "").split(",").map(&:to_i)
            if db_fps == fingerprint
              p "Fingerprint on line #{index} matched Fingerprint ID #{comm["id"]} in the DB"
            end
          end
        end
      end

    end

    def insert_all(results)
      @com = {}
      count = 0
      File.open(results).each_with_index do |line|
        p line
        if line.include?("FILE=")
          @com[:file_name] = line.split("FILE=")[1]
        end
        if line.include?("DURATION=")
          @com[:duration] = line.split("DURATION=")[1].to_i
        end
        if line.include?("FINGERPRINT=")
          @com[:fingerprint] = line.gsub("FINGERPRINT=", "").split(",").map(&:to_i)
          @com[:name] = 'fixme'
          p @com
          insert(@com, count)
          @com = {}
          count = count + 1
        end
      end
      p "Inserted #{count} Commercials"
    end

    def insert(commercial, count)
      @conn.exec_params("INSERT INTO tracktv (ID, NAME, DURATAION, FILE_NAME, FINGERPRINT) VALUES ('#{count+50}', '#{commercial[:name]}', '#{commercial[:duration]}', '#{commercial[:file_name]}', ARRAY#{commercial[:fingerprint]})")
    end

    def test_insert
      @conn.exec_prepared("ins", [1003, 'test', 10, 'test', '{1,2,3}'])
    end

    def show_all_commercials

    end
  end
end
