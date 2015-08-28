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
    I18n.locale = requested_locale || I18n.default_locale
  end

  # The locale requested by the user. Returns the first available value:
  # 1. a URL paramter called "locale"
  # 2. the +HTTP_ACCEPT_LANGUAGE+ header property
  def requested_locale
    validate_locale locale_from_url_params ||
      locale_from_accept_language_header
  end

  # Returns the given locale if localizations for it are available.
  # Returns nil otherwise.
  def validate_locale(locale)
    return if locale.blank?
    locale if locale.to_sym.in?(I18n.available_locales)
  end

  # The locale in the URL paramters
  def locale_from_url_params
    params[:locale]
  end

  # The two-character locale in the +HTTP_ACCEPT_LANGUAGE+ header field
  def locale_from_accept_language_header
    return if request.blank?
    return if request.env['HTTP_ACCEPT_LANGUAGE'].blank?

    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
