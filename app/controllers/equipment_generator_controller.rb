# Generates random Equipment values
class EquipmentGeneratorController < ApplicationController
  def armor
    # TODO: just make this an aggregate of armor, and
    # pick randomly from the different ones
    render json: {}
  end

  def armor_shield
    @shield_types = t(:shield_types)

    render json: @shield_types.sample
  end

  def weapon
    # TODO: just make this an aggregate, and
    # pick randomly from the different weapon generators
    @weapon_types = t(:weapon_types)

    render json: @weapon_types.sample
  end

  def weapon_axe
    @axe_types = t(:axe_types)

    render json: @axe_types.sample
  end

  def weapon_bow
    @bow_types = t(:bow_types)

    render json: @bow_types.sample
  end

  def weapon_club
    @club_types = t(:club_types)

    render json: @club_types.sample
  end

  def weapon_fist
    @fist_weapon_types = t(:fist_weapon_types)

    render json: @fist_weapon_types.sample
  end

  def weapon_flexible
    @flexible_types = t(:flexible_weapon_types)

    render json: @flexible_types.sample
  end

  def weapon_thrown
    @thrown_types = t(:thrown_weapon_types)

    render json: @thrown_types.sample
  end

  def weapon_polearm
    @polearm_types = t(:polearm_types)

    render json: @polearm_types.sample
  end

  def weapon_shortsword
    @shortsword_types = t(:shortsword_types)

    render json: @shortsword_types.sample
  end

  def weapon_sword
    @sword_types = t(:sword_types)

    render json: @sword_types.sample
  end
end
