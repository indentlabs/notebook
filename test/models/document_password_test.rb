require 'test_helper'

class DocumentPasswordTest < ActiveSupport::TestCase
  PASSWORD = 'correct horse'

  setup do
    @author   = users(:one)
    @document = Document.create!(user: @author, title: 'Chapter One', body: '<p>Text</p>', privacy: 'private')
  end

  test "protecting a document stores only a digest of the password" do
    assert @document.protect_with_password(PASSWORD)

    @document.reload
    assert @document.password_protected?
    assert_equal 'password', @document.privacy
    assert_not_includes @document.document_password_digest, PASSWORD
    assert @document.authenticate_document_password(PASSWORD)
    assert_not @document.authenticate_document_password('wrong password')
  end

  test "passwords have to be a reasonable length" do
    assert_not @document.protect_with_password('abcd')
    assert_includes @document.errors.full_messages.to_sentence, 'at least 5 characters'
    assert_equal 'private', @document.reload.privacy

    assert_not @document.protect_with_password('x' * 73)
    assert_equal 'private', @document.reload.privacy

    assert @document.protect_with_password('abcde')
    assert @document.reload.authenticate_document_password('abcde')
  end

  test "a blank password is rejected, even on a document that already has one" do
    assert_not @document.protect_with_password('')
    assert_equal 'private', @document.reload.privacy

    @document.protect_with_password(PASSWORD)
    assert_not @document.protect_with_password('')
    assert @document.reload.authenticate_document_password(PASSWORD)
  end

  test "changing the password replaces the old one" do
    @document.protect_with_password(PASSWORD)
    assert @document.protect_with_password('a new password')

    @document.reload
    assert_not @document.authenticate_document_password(PASSWORD)
    assert @document.authenticate_document_password('a new password')
  end

  test "removing protection clears the digest" do
    @document.protect_with_password(PASSWORD)

    assert @document.remove_password_protection('public')

    @document.reload
    assert_equal 'public', @document.privacy
    assert_nil @document.document_password_digest
  end

  test "protection can't be removed into an invalid state" do
    @document.protect_with_password(PASSWORD)

    assert_not @document.remove_password_protection('password')
    assert_not @document.remove_password_protection('nonsense')

    @document.reload
    assert @document.password_protected?
    assert @document.authenticate_document_password(PASSWORD)
  end

  test "a routine update can't take protection off" do
    @document.protect_with_password(PASSWORD)

    assert_not @document.update(privacy: 'public')
    assert_not @document.update(privacy: 'private')

    @document.reload
    assert @document.password_protected?
  end

  test "a routine update can't turn protection on" do
    assert_not @document.update(privacy: 'password')
    assert_equal 'private', @document.reload.privacy
  end

  test "a routine update can't replace the password" do
    @document.protect_with_password(PASSWORD)

    assert_not @document.update(document_password: 'a new password')
    assert @document.reload.authenticate_document_password(PASSWORD)
  end

  test "autosaving works on a protected document" do
    @document.protect_with_password(PASSWORD)

    assert Document.find(@document.id).update(body: '<p>New text</p>', title: 'New title', cached_word_count: 2)
    assert_equal 'New title', @document.reload.title
  end

  test "documents with old or unexpected privacy values can still be saved" do
    ['Private', '', nil, 'friends-only'].each do |legacy_value|
      @document.update_column(:privacy, legacy_value)

      assert Document.find(@document.id).update(body: "<p>Saved over #{legacy_value.inspect}</p>"), "Couldn't autosave over #{legacy_value.inspect}"
    end
  end

  test "new privacy values have to be real ones" do
    assert_not @document.update(privacy: 'friends-only')
    assert @document.update(privacy: 'public')
    assert @document.update(privacy: 'private')
  end

  test "the digest stays out of serialized documents" do
    @document.protect_with_password(PASSWORD)
    digest = @document.document_password_digest

    assert_not_includes @document.to_json, digest
    assert_not_includes @document.as_json.keys, 'document_password_digest'
    assert_not_includes @document.as_json(except: [:body]).keys, 'document_password_digest'
    assert_not_includes @document.to_xml, digest
    assert_not_includes @document.inspect, digest
  end

  test "the digest stays out of the admin panel" do
    %i[list show edit export].each do |section|
      assert_not_includes RailsAdmin.config('Document').send(section).fields.map(&:name), :document_password_digest, "Shown in rails_admin's #{section} section"
    end
  end

  test "labels and icons cover every privacy value" do
    assert_equal 'Private', Document.new(privacy: 'private').privacy_label
    assert_equal 'Public', Document.new(privacy: 'public').privacy_label
    assert_equal 'Password protected', Document.new(privacy: 'password').privacy_label
    assert_equal 'Private', Document.new(privacy: nil).privacy_label

    assert_equal 'lock', Document.new(privacy: 'private').privacy_icon
    assert_equal 'public', Document.new(privacy: 'public').privacy_icon
    assert_equal 'vpn_key', Document.new(privacy: 'password').privacy_icon
    assert_equal 'lock', Document.new(privacy: nil).privacy_icon
  end
end
