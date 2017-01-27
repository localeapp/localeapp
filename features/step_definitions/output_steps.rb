Then /^the output must match \/([^\/]+)\/([imx]*)$/ do |pattern, options|
  regexp = Regexp.new(pattern, options.each_char.inject(0) do |m, e|
    m | case e
      when ?i then Regexp::IGNORECASE
      when ?m then Regexp::MULTILINE
      when ?x then Regexp::EXTENDED
    end
  end)
  expect(last_command_started.output).to match regexp
end
