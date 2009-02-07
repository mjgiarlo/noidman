require File.dirname(__FILE__) + '/../test_helper'
require 'contracts_controller'

# Re-raise errors caught by the controller.
class ContractsController; def rescue_action(e) raise e end; end

class ContractsControllerTest < Test::Unit::TestCase
  fixtures :contracts

  def setup
    @controller = ContractsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:contracts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_contract
    old_count = Contract.count
    post :create, :contract => { }
    assert_equal old_count+1, Contract.count
    
    assert_redirected_to contract_path(assigns(:contract))
  end

  def test_should_show_contract
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_contract
    put :update, :id => 1, :contract => { }
    assert_redirected_to contract_path(assigns(:contract))
  end
  
  def test_should_destroy_contract
    old_count = Contract.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Contract.count
    
    assert_redirected_to contracts_path
  end
end
