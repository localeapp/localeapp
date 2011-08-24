i18n_major, i18n_minor, i18n_patchlevel = I18n::VERSION.split(/\./).map(&:to_i)
if i18n_major == 0
  if i18n_minor >= 6
    require 'localeapp/i18n_shims/oh_point_six_and_above'
  else
    require 'localeapp/i18n_shims/oh_point_five_and_below'
  end
end
