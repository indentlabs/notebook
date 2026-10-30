require 'test_helper'

class PageCollectionSubmissionAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @collection_owner = users(:one)
    @submitter        = users(:two)
    @stranger         = User.create!(email: 'stranger@example.com', password: 'password', password_confirmation: 'password')
    @collection = PageCollection.create!(user: @collection_owner, title: 'Collection', privacy: 'public', page_types: ['Character'], allow_submissions: true)
    @page       = Character.create!(user: @submitter, name: 'Submitted', privacy: 'public')
    @submission = PageCollectionSubmission.create!(page_collection: @collection, content: @page, user: @submitter, submitted_at: Time.current)
  end

  test "nobody can repoint a submission at another page or take it over" do
    other_page = Character.create!(user: @stranger, name: 'Other', privacy: 'public')
    sign_in @stranger

    assert_raises(ActionController::RoutingError) do
      patch page_collection_submission_path(@submission), params: {
        page_collection_submission: { content: "Character-#{other_page.id}", explanation: 'Mine now' }
      }
    end

    @submission.reload
    assert_equal @page.id, @submission.content_id
    assert_equal @submitter.id, @submission.user_id
  end

  test "the leftover submission pages are gone" do
    [
      -> { get new_page_collection_submission_path },
      -> { get page_collection_submission_path(@submission) },
      -> { get edit_page_collection_submission_path(@submission) }
    ].each do |request|
      assert_raises(ActionController::RoutingError, NameError) { request.call }
    end
  end

  test "the collection's owner can still remove a submission" do
    sign_in @collection_owner

    delete page_collection_submission_path(@submission)

    assert_redirected_to @collection
    assert_not PageCollectionSubmission.exists?(@submission.id)
  end

  test "people can still submit a page to a collection" do
    mine = Character.create!(user: @stranger, name: 'Mine', privacy: 'public')
    sign_in @stranger

    post page_collection_submissions_path, params: {
      page_collection_submission: { content: "Character-#{mine.id}", page_collection_id: @collection.id, explanation: 'Please' }
    }

    assert_redirected_to @collection
    assert PageCollectionSubmission.exists?(content: mine, user: @stranger)
  end
end
