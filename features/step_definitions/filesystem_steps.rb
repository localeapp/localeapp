Then /^the file "([^"]+)" must contain exactly:$/ do |path, content|
  cd ?. do
    expect(File.read(path)).to eq content + $/
  end
end
