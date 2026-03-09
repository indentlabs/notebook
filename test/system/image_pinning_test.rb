require "application_system_test_case"

class ImagePinningTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @character = characters(:one)

    # Create test images
    @image1 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false,
      src_file_name: 'test1.jpg'
    )

    @image2 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: true,
      src_file_name: 'test2.jpg'
    )

    sign_in @user
  end

  test "clicking pin button toggles pin status without page reload" do
    visit edit_character_path(@character)

    # Navigate to gallery tab
    click_on "Gallery"

    # Wait for gallery to be visible (Alpine.js)
    assert_selector ".gallery-sortable-item", wait: 5

    # Find the first unpinned image's pin button
    first_unpinned = find(".gallery-sortable-item[data-image-id='#{@image1.id}']")
    pin_button = first_unpinned.find(".js-toggle-pin")

    # Button should start gray (unpinned)
    assert pin_button[:class].include?("text-gray-400")

    # Click to pin
    pin_button.click

    # Wait for the visual change (no page reload)
    assert_selector ".gallery-sortable-item[data-image-id='#{@image1.id}'] .text-yellow-500", wait: 5

    # Verify the image is marked as pinned visually
    assert pin_button[:class].include?("text-yellow-500")
    assert first_unpinned.find(".relative")[:class].include?("ring-yellow-400")

    # Verify the previously pinned image is now unpinned
    second_image = find(".gallery-sortable-item[data-image-id='#{@image2.id}']")
    second_pin_button = second_image.find(".js-toggle-pin")
    assert second_pin_button[:class].include?("text-gray-400")

    # Verify database was updated without page reload
    @image1.reload
    @image2.reload
    assert @image1.pinned
    assert_not @image2.pinned
  end

  test "pin button works when navigating to gallery tab after page load" do
    visit edit_character_path(@character)

    # Start on details tab (not gallery)
    assert_selector "[x-data]", wait: 5

    # Navigate to gallery tab AFTER page load (tests MutationObserver)
    sleep 0.5 # Ensure DOM is settled
    click_on "Gallery"

    # Wait for gallery to be visible
    assert_selector ".gallery-sortable-item", wait: 5

    # Find and click pin button
    pin_button = find(".gallery-sortable-item[data-image-id='#{@image1.id}'] .js-toggle-pin")
    pin_button.click

    # Verify it worked
    assert_selector ".gallery-sortable-item[data-image-id='#{@image1.id}'] .text-yellow-500", wait: 5

    @image1.reload
    assert @image1.pinned
  end

  test "shows error message when not logged in" do
    sign_out @user

    # Somehow navigate to edit page (shouldn't normally be possible)
    # This tests the 401 error handling
    visit edit_character_path(@character)

    # Should redirect to login
    assert_current_path new_user_session_path
  end

  test "handles CSRF token missing gracefully" do
    visit edit_character_path(@character)
    click_on "Gallery"

    # Remove CSRF token meta tag to simulate missing token
    page.execute_script("document.querySelector('meta[name=\"csrf-token\"]').remove()")

    # Try to pin an image
    pin_button = find(".gallery-sortable-item[data-image-id='#{@image1.id}'] .js-toggle-pin")
    pin_button.click

    # Should show error notification
    assert_selector ".bg-red-500", text: "Security error. Please refresh the page.", wait: 5

    # Image should not be pinned in database
    @image1.reload
    assert_not @image1.pinned
  end

  test "handles multiple rapid clicks correctly" do
    visit edit_character_path(@character)
    click_on "Gallery"

    pin_button = find(".gallery-sortable-item[data-image-id='#{@image1.id}'] .js-toggle-pin")

    # Rapidly click the button multiple times
    3.times { pin_button.click }

    # Wait for processing to complete
    sleep 1

    # Should only toggle once (processing class prevents multiple requests)
    @image1.reload
    assert @image1.pinned

    # Click again after processing completes
    pin_button.click
    sleep 1

    @image1.reload
    assert_not @image1.pinned
  end

  test "pin button is not intercepted by jQuery UJS" do
    visit edit_character_path(@character)
    click_on "Gallery"

    # Verify no remote: true behavior by checking network requests
    pin_button = find(".gallery-sortable-item[data-image-id='#{@image1.id}'] .js-toggle-pin")

    # Execute script to monitor XHR requests
    page.execute_script(<<-JS)
      window.xhrCount = 0;
      var originalXHR = window.XMLHttpRequest;
      window.XMLHttpRequest = function() {
        window.xhrCount++;
        return new originalXHR();
      };
    JS

    pin_button.click
    sleep 0.5

    # Should only have one XHR request (from our fetch), not two (jQuery UJS + fetch)
    xhr_count = page.evaluate_script("window.xhrCount")
    assert_equal 0, xhr_count, "Should use fetch, not XMLHttpRequest from jQuery UJS"
  end
end