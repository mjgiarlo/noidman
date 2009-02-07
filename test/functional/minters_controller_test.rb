require File.dirname(__FILE__) + '/../test_helper'
require 'minters_controller'

# Re-raise errors caught by the controller.
class MintersController; def rescue_action(e) raise e end; end

class MintersControllerTest < Test::Unit::TestCase
  fixtures :minters

  def setup
    @controller = MintersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:minters)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_minter
    old_count = Minter.count
    post :create, :minter => { }
    assert_equal old_count+1, Minter.count
    
    assert_redirected_to minter_path(assigns(:minter))
  end

  def test_should_show_minter
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_minter
    put :update, :id => 1, :minter => { }
    assert_redirected_to minter_path(assigns(:minter))
  end
  
  def test_should_destroy_minter
    old_count = Minter.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Minter.count
    
    assert_redirected_to minters_path
  end
end
