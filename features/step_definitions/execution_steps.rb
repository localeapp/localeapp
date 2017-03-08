Then /^the exit status must be (\d+)$/ do |status|
  expect(last_command_started).to have_exit_status status.to_i
end
