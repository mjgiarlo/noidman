require File.dirname(__FILE__) + '/../test_helper'
require 'authorities_controller'

# Re-raise errors caught by the controller.
class AuthoritiesController; def rescue_action(e) raise e end; end

class AuthoritiesControllerTest < Test::Unit::TestCase
  fixtures :authorities

  def setup
    @controller = AuthoritiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:authorities)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_authority
    old_count = Authority.count
    post :create, :authority => { }
    assert_equal old_count+1, Authority.count
    
    assert_redirected_to authority_path(assigns(:authority))
  end

  def test_should_show_authority
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_authority
    put :update, :id => 1, :authority => { }
    assert_redirected_to authority_path(assigns(:authority))
  end
  
  def test_should_destroy_authority
    old_count = Authority.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Authority.count
    
    assert_redirected_to authorities_path
  end
end
