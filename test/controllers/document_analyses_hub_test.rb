require 'test_helper'

class DocumentAnalysesHubTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "the hub shows completed analyses with their reading grade" do
    document = Document.create!(user: @user, title: 'Analyzed', body: '<p>Some words</p>')
    DocumentAnalysis.create!(document: document, word_count: 2, flesch_kincaid_grade_level: 8, completed_at: Time.current)

    get analysis_hub_path

    assert_response :success
    assert_includes response.body, 'Grade: 8'
  end

  test "the hub still works when an analysis has no reading grade" do
    document = Document.create!(user: @user, title: 'Analyzed', body: '<p>Some words</p>')
    DocumentAnalysis.create!(document: document, word_count: 2, completed_at: Time.current)

    get analysis_hub_path

    assert_response :success
  end
end
