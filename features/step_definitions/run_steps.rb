def run_command(command, options = {})
  args = options[:args] || []
  run_simple "localeapp #{command} #{args.join ' '}"
end


When /^I pull all translations$/ do
  run_command :pull
end

When /^I push (JSON|YAML) translations file for locale "([^"]*)"/ do |format, locale_id|
  file_path_suffix = { json: ".json", yaml: ".yml" }[format.downcase.to_sym]
  run_command :push, args: %W[config/locales/#{locale_id}#{file_path_suffix}]
end

When /^I push all translations$/ do
  run_command :push, args: %w[config/locales]
end
