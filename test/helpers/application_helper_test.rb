require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper
  
  test "when user is logged-in, links characters" do
    log_in_user(:tolkien)
    
    link = link_if_present "Frodo Baggins", "character"
    
    assert_equal link_to("Frodo Baggins", characters(:frodo)), link
  end
  
  test "when user is not logged-in, just returns the given name" do
    link = link_if_present "Frodo Baggins", "character"
    
    assert_equal "Frodo Baggins", link
  end
  
  test "when name is not found, just return the given name" do
    log_in_user(:tolkien)
    
    link = link_if_present "Princess Zelda", "character"
    
    assert_equal "Princess Zelda", link
  end
  
  test "print_property makes a link" do
    log_in_user(:tolkien)
    
    property = print_property "The Ring-Bearer", "Frodo Baggins", "character"
    
    assert property.include? link_to("Frodo Baggins", characters(:frodo))
  end
end
