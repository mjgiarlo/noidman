# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_arkham_session_id'
  before_filter :log_action, :only => %w( create update destroy )
  
  def log_action
    # XXX set level appropriately
    # XXX pass in action and args
    AUDIT_LOGGER.info "CREATE blah blah blah"
  end
end
