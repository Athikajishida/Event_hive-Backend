require "test_helper"

class EventOrganizersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get event_organizers_create_url
    assert_response :success
  end
end
