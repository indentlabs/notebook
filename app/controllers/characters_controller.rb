# Controller for the Character model
class CharactersController < ContentController

  private

  def content_params
    params.require(:character).permit(content_param_list)
  end

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :age, :role, :gender, :age, :height, :weight, :haircolor,
      :facialhair, :eyecolor, :race, :skintone, :bodytype, :identmarks,
      :bestfriend, :religion, :politics, :prejudices, :occupation, :pets,
      :mannerisms, :birthday, :birthplace, :education, :background,
      :fave_color, :fave_food, :fave_possession, :fave_weapon, :fave_animal,
      :father, :mother, :spouse, :siblings, :archenemy, :notes, :private_notes
    ]
  end
end
