Before do
  ENV['FAKE_WEB_DURING_CUCUMBER_RUN'] = '1'
  @aruba_timeout_seconds = 15
end
