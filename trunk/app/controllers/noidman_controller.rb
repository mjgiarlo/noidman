class NoidmanController < ApplicationController
  require 'Noid'
  require 'uri'

  requires_authentication :using => Proc.new{ |u, p| u == 'test' && p == 'test' },
                          :except => [:index, :view, :get],
                          :realm => 'Authorized users only!'

  def index; end
  
  def view
    noid = Noid.new
    @recs = noid.get_all
    #@rec_pages = Paginator.new self, @recs.size, 10, @params['page']
    # XXX get pagination working
  end

  def dump
    noid = Noid.new
    @raw_recs = noid.dump_records
  end
  
  def create
    @url_to_noid_map = {}
    @invalid_urls = []
    @already_minted_urls = []

    noid = Noid.new  
    params['pid'].values.each do |url| 
      next if url.length < 1
      if not is_valid?( url )
        @invalid_urls << url
        next
      end
      if noid.has_minted?( url )
        @already_minted_urls << url
        next
      end
      @url_to_noid_map[url] = noid.mint_and_bind( url )
    end
  end    

  def edit
    @noid_id = params['id']
    noid = Noid.new @noid_id
    @the_url = noid.get( params['id'] ).chomp
    @size = @the_url.length
  end

  def delete
    @noid_id = params['id']
    noid = Noid.new @noid_id
    noid.bind_purge
    flash[:notice] = "SUCCESS: URL for ark:/#@noid_id was deleted!"
    redirect_to :action => 'view'
  end
  
  def replace
    @noid_id = params['id']
    @the_url = params['url']
    if is_valid?( @the_url )
      noid = Noid.new @noid_id
      if noid.has_minted?( @the_url )
        flash[:warn] = "NOTICE: 'ark:/#{noid.minted_by(@the_url)}' has already been minted for '#@the_url'!"
        redirect_to :action => 'edit', :id => @noid_id
      else
        if params['new']
          noid.bind_new( @the_url )
        else
          noid.bind_replace( @the_url ) 
        end   
        flash[:notice] = "SUCCESS: URL for ark:/#@noid_id was set to '#@the_url'"
        redirect_to :action => 'view'
      end
    else
      flash[:error] = "ERROR: URL '#@the_url' not valid"
      redirect_to :action => 'edit', :id => @noid_id
    end
  end
  
  def get
    noid = Noid.new
    @ark = noid.get( params['ark'] )
    if @request.request_uri.match(/\?\?$/)
      flash[:notice] = "This is a default commitment statement for ark:/#{ params['ark'] }"
      redirect_to :action => 'index'
    elsif @request.request_uri.match(/\?$/)
      redirect_to @ark + "&xsl="
    else
      redirect_to @ark
    end
    # XXX do some error checking here
  end
  
  def get_metadata; end
  
  def get_support; end

  def is_valid?( url )
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
