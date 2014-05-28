# Extracted from Rails to be available for standalone apps.
# @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/keys.rb
class Hash
  def symbolize_keys
    transform_keys{ |key| key.to_sym rescue key }
  end

  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end
end unless Hash.method_defined?(:symbolize_keys)
