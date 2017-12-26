class CharactersController < ContentController
  autocomplete :character, :name

  private

  def content_params
    params.require(:character).permit(content_param_list)
  end

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :age, :role, :gender, :age, :archetype, :height, :weight, :haircolor,
      :facialhair, :eyecolor, :skintone, :bodytype, :identmarks, :hairstyle,
      :religion, :politics, :prejudices, :occupation, :pets, :aliases, :race,
      :mannerisms, :birthday, :education, :background,
      :motivations, :flaws, :talents, :hobbies, :personality_type,
      :fave_color, :fave_food, :fave_possession, :fave_weapon, :fave_animal,
      :notes, :private_notes, :privacy,
      custom_attribute_values:     [:name, :value],
      siblingships_attributes:     [:id, :sibling_id, :_destroy],
      fatherships_attributes:      [:id, :father_id, :_destroy],
      motherships_attributes:      [:id, :mother_id, :_destroy],
      best_friendships_attributes: [:id, :best_friend_id, :_destroy],
      marriages_attributes:        [:id, :spouse_id, :_destroy],
      character_love_interests_attributes: [:id, :love_interest_id, :_destroy],
      archenemyship_attributes:    [:id, :archenemy_id, :_destroy],
      birthings_attributes:        [:id, :birthplace_id, :_destroy],
      childrenships_attributes:    [:id, :child_id, :_destroy],
      lingualisms_attributes:      [:id, :spoken_language_id, :_destroy],
      raceships_attributes:        [:id, :race_id, :_destroy]
    ]
  end
end
