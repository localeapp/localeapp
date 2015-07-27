module Localeapp
  module Formats
    FORMAT_SUFFIXES = {
      json: ".json".freeze,
      yaml: ".yml".freeze
    }.freeze

    def path_suffix_for_format(format)
      FORMAT_SUFFIXES.fetch format do
        fail InvalidFormatError, "unknown format: `#{format.inspect}'"
      end
    end
  end
end
