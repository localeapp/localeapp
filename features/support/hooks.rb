Before do
  set_environment_variable 'FAKE_WEB_DURING_CUCUMBER_RUN', '1'
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 15
end

# Globally @announce-cmd to track down slow cmd.
Aruba.configure do |config|
  config.before :command do |cmd|
    puts "$ #{cmd.commandline}"
  end
end
