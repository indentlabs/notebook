# Controller for the Character model
class CharactersController < ContentController
  autocomplete :character, :name,
    full: true # TODO: probably set full: false after testing
    #display_value: :tag_partial
    #extra_data: [:id]

  private

  def content_params
    params.require(:character).permit(content_param_list)
  end

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :age, :role, :gender, :age, :height, :weight, :haircolor,
      :facialhair, :eyecolor, :race, :skintone, :bodytype, :identmarks,
      :religion, :politics, :prejudices, :occupation, :pets,
      :mannerisms, :birthday, :birthplace, :education, :background,
      :fave_color, :fave_food, :fave_possession, :fave_weapon, :fave_animal,
      :spouse, :archenemy, :notes, :private_notes,
      siblingships_attributes:     [:id, :sibling_id, :_destroy],
      fatherships_attributes:      [:id, :father_id, :_destroy],
      motherships_attributes:      [:id, :mother_id, :_destroy],
      best_friendships_attributes: [:id, :best_friend_id, :_destroy],
      marriages_attributes:        [:id, :spouse_id, :_destroy],
      archenemyship_attributes:    [:id, :archenemy_id, :_destroy]
    ]
  end
end
