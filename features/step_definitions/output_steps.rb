def build_regexp(pattern, options)
  Regexp.new(pattern, options.each_char.inject(0) do |m, e|
    m | case e
      when ?i then Regexp::IGNORECASE
      when ?m then Regexp::MULTILINE
      when ?x then Regexp::EXTENDED
    end
  end)
end


Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  expect(all_output).to match build_regexp(pattern, options)
end
