# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_to_self( url )
    "<a href='/ark:/#{h(url)}' target='_blank'>ark:/#{h(url)}</a>"
  end

  def link_to_metadata( url )
    "[<a href='/ark:/#{h(url)}?' target='_blank'>i</a>]"
  end

  def link_to_support( url )
    "[<a href='/ark:/#{h(url)}??' target='_blank'>Statement</a>]"
  end

  def url_hack( url )
    h(url).gsub(/\//, '/&#8203;')
  end

end
