require 'test_helper'

class BooksCharactersCardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user.update!(upload_bandwidth_kb: 5000)
    sign_in @user
    @universe = Universe.create!(user: @user, name: 'Card Universe', privacy: 'private')
    @book     = Book.create!(user: @user, name: 'Card Book', privacy: 'private', universe: @universe)
  end

  test "show page lists universe characters with their thumbnail or the character icon" do
    with_image = Character.create!(user: @user, universe: @universe, name: 'Amelia')
    Character.create!(user: @user, universe: @universe, name: 'Bertram')
    upload = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: with_image.id,
      privacy: 'public',
      src: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
    )

    get book_path(@book)

    assert_response :success
    assert_match 'Amelia', response.body
    assert_match 'Bertram', response.body
    assert_select 'img[alt=?]', 'Amelia'
  ensure
    upload&.destroy
  end
end
