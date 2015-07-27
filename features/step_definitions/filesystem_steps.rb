LOCALES_DIRECTORY = "config/locales".freeze

def glob(pattern)
  cd('.') { Dir[pattern] }
end

def json_locale_file(locale_id)
  cd '.' do
    JSON.parse(File.read("#{LOCALES_DIRECTORY}/#{locale_id}.json"))
  end
end


Given /a JSON translations file for locale "([^"]*)"/ do |locale_id|
  write_file "#{LOCALES_DIRECTORY}/#{locale_id}.json", JSON.generate(
    valid_translation_data["translations"][locale_id]
  )
end


Then /^locale files with "([^"]*)" suffix must exist$/ do |suffix|
  paths = glob File.join(LOCALES_DIRECTORY, ["*", suffix].join)
  expect(paths.size).to be == 2
  expect(paths).to all be_an_existing_file
end

Then /^JSON locale files must include my translations$/ do
  %w[en es].each do |locale_id|
    expect(json_locale_file(locale_id)[locale_id]).to eq(
      valid_translation_data["translations"][locale_id]
    )
  end
end
