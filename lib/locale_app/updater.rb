require 'i18n/core_ext/hash'

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
      remove_child_keys!(sub_hash[current_key], keys)
      if sub_hash[current_key].empty?
        sub_hash.delete(current_key)
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
