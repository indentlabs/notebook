require 'active_support/concern'

# Sets the locale for every request, from the first available value among
# the following:
# 1. a URL parameter called "locale", ex. +?locale=en+
# 2. the +HTTP_ACCEPT_LANGUAGE+ header property
# 3. the default locale in +I18n.default_locale+
module Localized
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  # Sets +I18n.locale+ from the first available value among the following:
  # 1. a URL parameter called "locale", ex. +?locale=en+
  # 2. the +HTTP_ACCEPT_LANGUAGE+ header property
  # 3. the default locale in +I18n.default_locale+
  def set_locale
    I18n.locale = params[:locale] ||
      locale_from_accept_language_header ||
      I18n.default_locale
  end

  # The two-character locale in the +HTTP_ACCEPT_LANGUAGE+ header field
  def locale_from_accept_language_header
    return unless request
    return unless request.env['HTTP_ACCEPT_LANGUAGE']
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
