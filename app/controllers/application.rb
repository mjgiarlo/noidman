# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'uri'

class ApplicationController < ActionController::Base
  
  def valid?( url )
    return false if url.length < 10
    begin
      uri = URI.parse(url)
      if uri.class != URI::HTTP and uri.class != URI::HTTPS
        return false
      end
    rescue URI::InvalidURIError
      return false
    else
      return true
    end
  end

end