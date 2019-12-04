require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get Index" do
    get pages_Index_url
    assert_response :success
  end

end
