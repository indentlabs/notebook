class LabController < ApplicationController
  layout 'app', only: [:pinboard]
  layout 'nostyle', only: [:crossword]

  def pinboard

  end

  def dice
  end

  def babel
    EasyTranslate.api_key = ENV['GOOGLE_TRANSLATE_API_KEY']

    @translations = [["afrikaans", "amarach"], ["albanian", "amarach"], ["arabic", "amarach"], ["belarusian", "amarach"], ["bulgarian", "amarach"], ["catalan", "Amarachi"], ["chinese_simplified", "amarach"], ["chinese_traditional", "amarach"], ["croatian", "Amarachi"], ["czech", "Amarachi"], ["danish", "Amarach"], ["dutch", "Amarach"], ["estonian", "Amarachi"], ["filipino", "Amarach"], ["finnish", "Amarachi"], ["french", "Amarach"], ["galician", "Amarachi"], ["german", "Amarach"], ["greek", "amarach"], ["hebrew", "amarach"], ["hindi", "Amrc"], ["hungarian", "Amarachi"], ["icelandic", "Amarachi"], ["indonesian", "Amarach"], ["irish", "tomorrow"], ["italian", "Amarach"], ["japanese", "amarach"], ["korean", "amarach"], ["latin", "amarach"], ["latvian", "Amárach"], ["lithuanian", "Amarachi"], ["macedonian", "amarach"], ["malay", "Amarach"], ["maltese", "Amárach"], ["norwegian", "Amarach"], ["persian", "amarach"], ["polish", "Amarach"], ["portuguese", "Amarach"], ["romanian", "Amarachi"], ["russian", "amarach"], ["serbian", "Amarachi"], ["slovak", "Amarach"], ["slovenian", "Amarachi"], ["spanish", "Amarach"], ["swahili", "amarach"], ["swedish", "Amarach"], ["thai", "amarach"], ["turkish", "Amarachi"], ["ukrainian", "amarach"], ["vietnamese", "amarach"], ["welsh", "amarach"], ["yiddish", "amarach"]]

    if request.method == 'POST' && params.include?('query') && params[:query].present?
      @translations = []

      EasyTranslate::LANGUAGES.values.each do |language|
        next if language == 'english'
        @translations << [
          language,
          EasyTranslate.translate(params[:query], from: language, to: 'english')
        ]
      end

      # Sort translations by how similar they are to the original word, and then reverse sorting (to get most-different first)
      @translations.sort_by! { |translation| Levenshtein.distance(params[:query].downcase, translation.second.downcase) }
      @translations.reverse!
    end
  end

  def crossword

  end
end
