require 'test_helper'

# Password protection on worldbuilding pages. Every page type gets it from IsContentPage,
# so the basics run against all of them.
class PagePasswordTest < ActiveSupport::TestCase
  PASSWORD = 'correct horse'

  setup do
    @owner = users(:one)
    @page  = Character.create!(user: @owner, name: 'Secret Person', privacy: 'private')
  end

  test "every page type can be password protected" do
    Rails.application.config.content_types[:all].each do |page_type|
      page = page_type.create!(user: @owner, name: "A #{page_type.name}", privacy: 'private')

      assert page.protect_with_password(PASSWORD), "#{page_type.name}: #{page.errors.full_messages.to_sentence}"

      page = page_type.find(page.id)
      assert page.password_protected?, page_type.name
      assert page.authenticate_page_password(PASSWORD), page_type.name
      assert_not page.authenticate_page_password('wrong password'), page_type.name
      assert page.remove_password_protection('public'), page_type.name
      assert_equal 'public', page.reload.privacy
    end
  end

  test "timelines aren't one of the page types that can be protected yet" do
    assert_not Timeline.include?(HasPasswordProtection)
  end

  test "protecting a page stores only a digest of the password, away from the page's own columns" do
    assert @page.protect_with_password(PASSWORD)

    @page.reload
    assert_equal 'password', @page.privacy
    assert_not Character.column_names.any? { |column| column.include?('password') }
    assert_not_includes @page.page_password.password_digest, PASSWORD
    assert @page.authenticate_page_password(PASSWORD)
  end

  test "passwords have to be a reasonable length" do
    assert_not @page.protect_with_password('abcd')
    assert_includes @page.errors[:password].to_sentence, 'at least 5 characters'
    assert_equal 'private', @page.reload.privacy

    assert_not @page.protect_with_password('x' * 73)
    assert_equal 'private', @page.reload.privacy

    assert @page.protect_with_password('abcde')
    assert @page.reload.authenticate_page_password('abcde')
  end

  test "a blank password is rejected, even on a page that already has one" do
    assert_not @page.protect_with_password('')
    assert_equal 'private', @page.reload.privacy
    assert_equal 0, PagePassword.where(page: @page).count

    @page.protect_with_password(PASSWORD)
    assert_not @page.reload.protect_with_password('')
    assert @page.reload.authenticate_page_password(PASSWORD)
  end

  test "changing the password replaces the old one" do
    @page.protect_with_password(PASSWORD)
    assert @page.reload.protect_with_password('a new password')

    @page.reload
    assert_not @page.authenticate_page_password(PASSWORD)
    assert @page.authenticate_page_password('a new password')
    assert_equal 1, PagePassword.where(page: @page).count
  end

  test "removing protection deletes the password" do
    @page.protect_with_password(PASSWORD)

    assert @page.reload.remove_password_protection('public')

    assert_equal 'public', @page.reload.privacy
    assert_nil @page.page_password
    assert_equal 0, PagePassword.where(page: @page).count
  end

  test "protection can't be removed into an invalid state" do
    @page.protect_with_password(PASSWORD)

    assert_not @page.reload.remove_password_protection('password')
    assert_not @page.reload.remove_password_protection('friends-only')
    assert @page.reload.password_protected?
    assert @page.authenticate_page_password(PASSWORD)
  end

  test "a routine update can't take protection off" do
    @page.protect_with_password(PASSWORD)

    assert_not @page.reload.update(privacy: 'public')
    assert @page.reload.password_protected?
  end

  test "a routine update can't turn protection on" do
    assert_not @page.update(privacy: 'password')
    assert_equal 'private', @page.reload.privacy
  end

  test "editing a protected page still works" do
    @page.protect_with_password(PASSWORD)

    assert Character.find(@page.id).update(name: 'New name', role: 'New role')
    assert_equal 'New name', @page.reload.name
    assert @page.password_protected?
  end

  test "pages with old or unexpected privacy values can still be saved" do
    ['Private', '', nil, 'friends-only'].each do |legacy_value|
      @page.update_column(:privacy, legacy_value)

      assert Character.find(@page.id).update(name: "Saved over #{legacy_value.inspect}"), "Couldn't save over #{legacy_value.inspect}"
    end
  end

  test "new privacy values have to be real ones" do
    assert_not @page.update(privacy: 'friends-only')
    assert @page.update(privacy: 'public')
    assert @page.update(privacy: 'private')
  end

  test "the password survives the trash, so a restored page is still protected" do
    @page.protect_with_password(PASSWORD)

    @page.destroy
    assert_equal 1, PagePassword.where(page_type: 'Character', page_id: @page.id).count

    restored = Character.with_deleted.find(@page.id)
    restored.restore
    assert Character.find(@page.id).authenticate_page_password(PASSWORD)
  end

  test "the password goes when the page is gone for good" do
    @page.protect_with_password(PASSWORD)

    Character.find(@page.id).really_destroy!

    assert_equal 0, PagePassword.where(page_type: 'Character', page_id: @page.id).count
  end

  test "the digest stays out of serialized pages" do
    @page.protect_with_password(PASSWORD)
    digest = @page.page_password.password_digest

    assert_not_includes @page.to_json, digest
    assert_not_includes @page.to_json(include: :page_password), digest
    assert_not_includes @page.page_password.to_json, digest
    assert_not_includes @page.page_password.inspect, digest
    assert_not_includes ContentSerializer.new(@page.reload, viewing_user: @owner).data.to_json, digest
  end

  test "the fingerprint changes along with the password, and differs between pages" do
    @page.protect_with_password(PASSWORD)
    first = @page.reload.password_fingerprint

    other = Location.create!(user: @owner, name: 'Elsewhere', privacy: 'private')
    other.protect_with_password(PASSWORD)
    assert_not_equal first, other.reload.password_fingerprint

    @page.protect_with_password(PASSWORD)
    assert_not_equal first, @page.reload.password_fingerprint

    @page.remove_password_protection('private')
    assert_nil @page.reload.password_fingerprint
  end

  test "labels and icons cover every privacy value" do
    assert_equal 'Private', Character.new(privacy: 'private').privacy_label
    assert_equal 'Public', Character.new(privacy: 'public').privacy_label
    assert_equal 'Password protected', Character.new(privacy: 'password').privacy_label
    assert_equal 'Private', Character.new(privacy: nil).privacy_label

    assert_equal 'lock', Character.new(privacy: 'private').privacy_icon
    assert_equal 'public', Character.new(privacy: 'public').privacy_icon
    assert_equal 'vpn_key', Character.new(privacy: 'password').privacy_icon
  end

  test "the page and document password rules agree" do
    assert_equal Document::PASSWORD_LENGTH, HasPasswordProtection::PASSWORD_LENGTH
    assert_equal Document::PRIVACY_LABELS, HasPasswordProtection::PRIVACY_LABELS
  end
end
