require 'test_helper'

# HasContentGroupers.relates defines inverse_* associations (e.g.
# Character#inverse_fathers, through Character#inverse_fatherships). These used
# to point at the wrong class, so every one of them raised when used, and
# RailsAdmin list pages for most content types 500'd while inspecting them.
class ContentGrouperInverseAssociationsTest < ActiveSupport::TestCase
  setup { Rails.application.eager_load! }

  test "every inverse content grouper association resolves and can be queried" do
    inverse_associations = ApplicationRecord.descendants.flat_map do |model|
      model.reflect_on_all_associations
        .select { |reflection| reflection.name.to_s.start_with?('inverse_') && reflection.through_reflection? }
        .map { |reflection| [model, reflection] }
    end
    assert_not_empty inverse_associations

    inverse_associations.each do |model, reflection|
      label = "#{model.name}##{reflection.name}"
      assert_not_nil reflection.source_reflection, "#{label} has no source association"
      record = model.new(id: 0)
      [reflection.through_reflection.name, reflection.name].each do |association|
        record.public_send(association).to_a
      rescue StandardError => e
        flunk "#{model.name}##{association} raised #{e.class}: #{e.message}"
      end
    end
  end

  test "inverse associations find the pages that link to this one" do
    user = users(:one)
    kid  = Character.create!(name: 'Kid', user: user)
    dad  = Character.create!(name: 'Dad', user: user)
    Fathership.create!(character: kid, father: dad, user: user)

    assert_equal [dad], kid.fathers.to_a
    assert_equal [kid], dad.inverse_fathers.to_a
  end
end
