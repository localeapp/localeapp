Before do
  ENV['FAKE_WEB_DURING_CUCUMBER_RUN'] = '1'
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 15
end

# Globally @announce-cmd to track down slow cmd.
Aruba.configure do |config|
  config.before_cmd do |cmd|
    puts "$ '#{cmd}'"
  end
end
