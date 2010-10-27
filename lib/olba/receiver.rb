require 'yaml'

module Olba
  class Receiver
    # when we last asked the service for updates
    attr_accessor :polled_at
    
    # the last time the service had updates for us
    attr_accessor :updated_at

    def initialize
      initialize_cluster_log
      @polled_at  = cluster_log[:polled_at]
      @updated_at = cluster_log[:updated_at]
    end

    def initialize_cluster_log
      unless File.exists?(Olba.configuration.cluster_log)
        File.open(Olba.configuration.cluster_log, 'w') do |f|
          f.write({:polled_at => Time.now.to_i, :updated_at => Time.now.to_i}.to_yaml)
        end
      end
    end

    def cluster_log
      yml = YAML.load_file(Olba.configuration.cluster_log)
      puts '---'
      puts 'cluster: ' << yml.inspect
      puts 'self   : ' << {:polled_at => @polled_at, :updated_at => @updated_at}.inspect
      Olba.log(yml.inspect)
      yml
    end

    def cluster_updated?
      puts @updated_at != cluster_log[:updated_at] ? 'UPDATED'  : 'NOT UPDATED'
      @updated_at != cluster_log[:updated_at]
    end

    def needs_polling?
      puts cluster_log[:polled_at] < (Time.now.to_i - Olba.configuration.poll_interval) ? 'DO POLL' : 'no POLL'
      cluster_log[:polled_at] < (Time.now.to_i - Olba.configuration.poll_interval)
    end

    def poll!
      # get updated_at from server
      puts 'Polling'
      File.open(Olba.configuration.cluster_log, 'w') do |f|
        f.write({:polled_at => Time.now.to_i, :updated_at => Time.now.to_i}.to_yaml)
      end
    end

    def get_translations!
      puts 'Getting translations'
    end
  end
end
