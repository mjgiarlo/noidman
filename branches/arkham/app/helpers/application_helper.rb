# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_list_id( page )
    (page == @controller.controller_name) ? 'current' : page
  end
end
