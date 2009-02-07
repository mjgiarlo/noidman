require File.dirname(__FILE__) + '/../test_helper'
require 'identifiers_controller'

# Re-raise errors caught by the controller.
class IdentifiersController; def rescue_action(e) raise e end; end

class IdentifiersControllerTest < Test::Unit::TestCase
  fixtures :identifiers

  def setup
    @controller = IdentifiersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:identifiers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_identifier
    old_count = Identifier.count
    post :create, :identifier => { }
    assert_equal old_count+1, Identifier.count
    
    assert_redirected_to identifier_path(assigns(:identifier))
  end

  def test_should_show_identifier
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_identifier
    put :update, :id => 1, :identifier => { }
    assert_redirected_to identifier_path(assigns(:identifier))
  end
  
  def test_should_destroy_identifier
    old_count = Identifier.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Identifier.count
    
    assert_redirected_to identifiers_path
  end
end
