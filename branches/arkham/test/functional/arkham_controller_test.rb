require File.dirname(__FILE__) + '/../test_helper'
require 'arkham_controller'

# Re-raise errors caught by the controller.
class ArkhamController; def rescue_action(e) raise e end; end

class ArkhamControllerTest < Test::Unit::TestCase
  def setup
    @controller = ArkhamController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
