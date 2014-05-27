module Localeapp
  module CLI
    class Daemon < Command
      def execute(options)
        interval = options[:interval].to_i

        if interval <= 0
          exit_now! "interval must be a positive integer greater than 0", 1
        end

        if options[:background]
          run_in_background(interval)
        else
          update_loop(interval)
        end
      end

      def update_loop(interval)
        loop do
          do_update
          sleep interval
        end
      end

      def do_update
        Localeapp::CLI::Update.new.execute
      end

      def run_in_background(interval)
        kill_existing

        STDOUT.reopen(File.open(Localeapp.configuration.daemon_log_file, 'a'))
        pid = fork do
          Signal.trap('HUP', 'IGNORE')
          update_loop(interval)
        end
        Process.detach(pid)

        File.open(Localeapp.configuration.daemon_pid_file, 'w') {|f| f << pid}
      end

      def kill_existing
        if File.exist? Localeapp.configuration.daemon_pid_file
          begin
            daemon_pid = File.read(Localeapp.configuration.daemon_pid_file)
            Process.kill("QUIT", daemon_pid.to_i)
          rescue Errno::ESRCH
            File.delete(Localeapp.configuration.daemon_pid_file)
          end
        end
      end
    end
  end
end
