# AUDIT: Find a better way of doing this
begin
  require 'i18n/core_ext/hash'
rescue LoadError
  # Assume that we're in rails 2.3 and AS supplies deep_merge
end

class Hash
  def remove_flattened_key!(locale, key)
    keys = I18n.normalize_keys(locale, key, '').map(&:to_s)
    current_key = keys.shift
    remove_child_keys!(self[current_key], keys)
    self
  end

  def remove_child_keys!(sub_hash, keys)
    current_key = keys.shift
    if keys.empty?
      sub_hash.delete(current_key)
    else
      child_hash = sub_hash[current_key]
      unless child_hash.nil?
        remove_child_keys!(child_hash, keys)
        if child_hash.empty?
          sub_hash.delete(current_key)
        end
      end
    end
  end
end

module LocaleApp
  class Updater
    def self.update(data)
      data['translations'].keys.each do |short_code|
        filename = File.join(LocaleApp.configuration.translation_data_directory, "#{short_code}.yml")
        translations = YAML.load(File.read(filename))
        new_data = { short_code => data['translations'][short_code] }
        translations.deep_merge!(new_data)
        data['deleted'].each do |key|
          translations.remove_flattened_key!(short_code, key)
        end
        File.open(filename, "w+") do |file|
          file.write translations.ya2yaml[5..-1]
        end
      end
    end
  end
end
