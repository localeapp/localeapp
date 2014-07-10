require 'fileutils'

module Localeapp
  class Updater

    def update(data)
      data['locales'].each do |short_code|
        filename = File.join(Localeapp.configuration.translation_data_directory, "#{short_code}.yml")

        if File.exist?(filename)
          translations = Localeapp.load_yaml_file(filename)
          if data['translations'] && data['translations'][short_code]
            new_data = { short_code => data['translations'][short_code] }
            translations.deep_merge!(new_data)
          end
        else
          translations = { short_code => data['translations'][short_code] }
        end

        if data['deleted']
          data['deleted'].each do |key|
            remove_flattened_key!(translations, short_code, key)
          end
        end

        if translations[short_code]
          atomic_write(filename) do |file|
            file.write generate_yaml(translations)
          end
        end
      end
    end

    def dump(data)
      data.each do |locale, translations|
        filename = File.join(Localeapp.configuration.translation_data_directory, "#{locale}.yml")
        atomic_write(filename) do |file|
          file.write generate_yaml({locale => translations})
        end
      end
    end

    private

    def generate_yaml(translations)
      if defined?(Psych) && defined?(Psych::VERSION)
        Psych.dump(translations, :line_width => -1)[4..-1]
      else
        translations.ya2yaml[5..-1]
      end
    end

    def remove_flattened_key!(hash, locale, key)
      keys = I18n.normalize_keys(locale, key, '').map(&:to_s)
      current_key = keys.shift
      remove_child_keys!(hash[current_key], keys)
      hash
    end

    def remove_child_keys!(sub_hash, keys)
      return if sub_hash.nil?
      current_key = keys.shift
      if keys.empty?
        # delete key except if key is now used as a namespace for a child_hash
        unless sub_hash[current_key].is_a?(Hash)
          sub_hash.delete(current_key)
        end
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

    # originally from ActiveSupport
    def atomic_write(file_name, temp_dir = Dir.tmpdir)
      target_dir = File.dirname(file_name)
      unless File.directory?(target_dir)
        raise "Could not write locale file, please make sure that #{target_dir} exists and is writable"
      end

      permissions = File.stat(file_name).mode if File.exist?(file_name)

      temp_file = Tempfile.new(File.basename(file_name), temp_dir)
      yield temp_file
      temp_file.close
      # heroku has /tmp on a different fs
      # so move first to sure they're on the same fs
      # so rename will work
      FileUtils.mv(temp_file.path, "#{file_name}.tmp")
      File.rename("#{file_name}.tmp", file_name)

      # chmod the file to its previous permissions
      # or set default permissions to 644
      File.chmod(permissions ? permissions : 0644 , file_name)
    end
  end
end
