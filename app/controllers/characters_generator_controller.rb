# Generates random Character values
class CharactersGeneratorController < ApplicationController
  def age
    @upper_limit = 100
    @lower_limit = 2

    render json: rand(@lower_limit...@upper_limit)
  end

  def bodytype
    @possible_types = t('generators.characters.body_types')

    render json: @possible_types.sample
  end

  def eyecolor
    @possible_colors = t('generators.characters.eye_colors')

    render json: @possible_colors.sample
  end

  def facialhair
    @possible_styles = t('generators.characters.facial_hair_styles')

    render json: @possible_styles.sample
  end

  def haircolor
    @possible_colors = t('generators.characters.hair_colors')

    render json: @possible_colors.sample
  end

  def hairstyle
    @possible_styles = t('generators.characters.hair_styles')

    render json: @possible_styles.sample
  end

  def height
    @upper_foot_limit = 6
    @lower_foot_limit = 2
    @upper_inch_limit = 11
    @lower_inch_limit = 0

    render json: [
      rand(@lower_foot_limit...@upper_foot_limit), "'",
      rand(@lower_inch_limit...@upper_inch_limit), '"'
    ].join
  end

  def identifyingmark
    @possible_marks = t('generators.characters.identifying_marks')
    @possible_locations = t('generators.characters.identifying_mark_locations')

    render json: [
      @possible_marks.sample, t('generators.characters.on_the'), @possible_locations.sample
    ].join(' ') .capitalize
  end

  def name
    @male_first_names = t('generators.characters.names.male_first_names')
    @female_first_names = t('generators.characters.names.female_first_names')
    @last_names = t('generators.characters.names.last_names')

    @all_first_names = [] + @male_first_names + @female_first_names
    @all_last_names  = [] + @last_names

    render json: [@all_first_names.sample, @all_last_names.sample].join(' ')
  end

  def race
    @possible_races = t('generators.characters.races')

    render json: @possible_races.sample
  end

  def skintone
    @possible_tones = t('generators.characters.skin_tones')

    render json: @possible_tones.sample
  end

  def weight
    @upper_limit = 240
    @lower_limit = 80

    render json: rand(@lower_limit...@upper_limit)
  end
end
