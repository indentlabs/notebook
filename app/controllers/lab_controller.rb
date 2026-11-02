class LabController < ApplicationController
  layout 'app', only: [:pinboard]
  layout 'nostyle', only: [:crossword]

  def pinboard

  end

  def dice
  end

  def crossword

  end
end
