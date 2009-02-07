require 'Noid'

class NoidmanController < ApplicationController
  before_filter :url_munge
  before_filter :get_new_noid,   :only => [:view, :feed, :dump, :create, :search, :get]
  before_filter :get_known_noid, :only => [:edit, :delete, :replace]

  
  # Using apache mod_auth, since running behind mod_rewrite makes simple_http_auth infiniloop
  #
  #  requires_authentication :using => Proc.new{ |u, p| u == 'something' && p == 'something_else' },
  #                          :except => [:index, :view, :get],
  #                          :realm => 'Authorized users only'

  def url_munge
    params[:id] += "/#{params[:broken]}" if not params[:broken].nil?
  end

  def get_new_noid
    @noid = Noid.new :noid_dir => AppConfig.noid_directory, 
                     :noid_cmd => AppConfig.noid_script 
  end

  def get_known_noid
    @noid_id = params[:id]
    @noid = Noid.new :noid_id => @noid_id, 
                     :noid_dir => AppConfig.noid_directory, 
                     :noid_cmd => AppConfig.noid_script
  end

  # stub actions for views that require no logic
  def index; end

  def about; end
  
  def help; end

  # bona fide actions
  def view
    #@recs = noid.get_all( params[:bound] ) if params[:bound] == 'false'
    # XXX clean this up
    @start_record = ( params[:start] and params[:start].to_i > 0 ) ?
      params[:start].to_i : 
      0
    @recs_per_page = 10
    @recs = @noid.get_all
    @total_recs = @recs.length
    @sort = params[:sort]
    @sort_by_url = true if @sort == 'URL'
    ark_list = @sort_by_url ? @recs.values : @recs.keys
    @arks = ark_list.sort.slice( @start_record, @recs_per_page )
  end

  def feed
    @noid_to_cdate_map = @noid.last_n_mints( 10 ).delete_if { |x| x[2].empty? }
    @number_of_mints = @noid_to_cdate_map.length
    render :layout => false
    # XXX format dates, add atom feature, enable auto-discovery
  end

  def dump
    @raw_recs = @noid.dump_records
  end
  
  def create
    @url_to_noid_map = {}
    @invalid_urls = []
    @already_minted_urls = []
    params[:pid].values.each do |url| 
      next if url.length < 1
      if not valid?( url )
        @invalid_urls << url
        AUDIT_LOGGER.error "CREATE #{url} not valid error"
        next
      end
      if @noid.has_minted?( url )
        @already_minted_urls << url
        AUDIT_LOGGER.error "CREATE #{url} already minted error"
        next
      end
      @url_to_noid_map[url] = @noid.mint_and_bind( url )
      AUDIT_LOGGER.info "CREATE #{@url_to_noid_map[url]} for #{url}" 
    end
    @no_noids = true if params[:pid].values.nitems == 0
  end    

  def search
    @query = params[:query]
    @start_match = ( params[:start] and params[:start].to_i > 0 ) ? params[:start].to_i : 0
    @matches_per_page = 10
    @matches = @noid.find( @query )
    @total_matches = @matches.length
  end

  def edit
    @the_url = @noid.get( @noid_id ).chomp
    @size = @the_url.length
  end

  def delete
    @noid.bind_purge
    AUDIT_LOGGER.info "DELETE #@noid_id"
    flash[:notice] = "SUCCESS: URL for ark:/#@noid_id was deleted!"
    redirect_to :action => 'view'
  end
  
  def replace
    @the_url = params[:url]
    if valid?( @the_url )
      if @noid.has_minted?( @the_url )
        flash[:warn] = "NOTICE: 'ark:/#{noid.minted_by(@the_url)}' has already been minted for '#@the_url'!"
        AUDIT_LOGGER.error "REPLACE #@the_url already minted error"
        redirect_to :action => 'edit', :id => @noid_id
      else
        if params[:new]
          @noid.bind_new( @the_url )
          AUDIT_LOGGER.info "CREATE #@noid_id for #@the_url"
        else
          @noid.bind_replace( @the_url )
          AUDIT_LOGGER.info "REPLACE #@noid_id with #@the_url" 
        end   
        flash[:notice] = "SUCCESS: URL for ark:/#@noid_id was set to '#@the_url'"
        redirect_to :action => 'view'
      end
    else
      flash[:error] = "ERROR: URL '#@the_url' not valid"
      AUDIT_LOGGER.error "REPLACE #@the_url not valid error"
      redirect_to :action => 'edit', :id => @noid_id
    end
  end
  
  def get
    @ark = @noid.get( params[:ark] )
    if request.request_uri =~ /\?\?$/
      redirect_to :action => 'get_support', :id => @ark
    elsif request.request_uri =~ /\?$/
      redirect_to :action => 'get_metadata', :id => @ark
    else
      redirect_to @ark
    end
    # XXX do some error checking here
  end

  def get_metadata
    @ark = params[:id]
    # XXX work on these rules
    if @ark =~ /diglib.princeton.edu/
      redirect_to @ark + "&xsl="
      # XXX use net/http to grab these and make ERC records on the fly 
    else
      # do something else
    end     
  end
  
  def get_support
    flash[:notice] = "This is a default commitment statement for ark:/#{ params[:ark] }"
    # XXX generate ERC record for this
  end

end
