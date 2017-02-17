Given /^a file "([^"]+)" with content:$/ do |path, content|
  cd ?. do
    File.write(path, content + $/)
  end
end


Then /^the file "([^"]+)" must contain exactly:$/ do |path, content|
  cd ?. do
    expect(File.read(path)).to eq content + $/
  end
end
