class AuthoritiesController < ApplicationController
  before_filter :find_authority, :only => %w( edit show update destroy )

  # GET /authorities
  # GET /authorities.xml
  def index
    @authorities = Authority.find( :all )

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @authorities.to_xml }
    end
  end

  # GET /authorities/1
  # GET /authorities/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @authority.to_xml }
    end
  end

  # GET /authorities/new
  def new
    @authority = Authority.new
  end

  # GET /authorities/1;edit
  def edit
  end

  # POST /authorities
  # POST /authorities.xml
  def create
    @authority = Authority.new( params[:authority] )

    respond_to do |format|
      if @authority.save
        flash[:notice] = 'Authority was successfully created.'
        format.html { redirect_to authority_url(@authority) }
        format.xml  { head :created, :location => authority_url(@authority) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @authority.errors.to_xml }
      end
    end
  end

  # PUT /authorities/1
  # PUT /authorities/1.xml
  def update
    respond_to do |format|
      if @authority.update_attributes( params[:authority ])
        flash[:notice] = 'Authority was successfully updated.'
        format.html { redirect_to authority_url(@authority) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @authority.errors.to_xml }
      end
    end
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.xml
  def destroy
    @authority.destroy

    respond_to do |format|
      format.html { redirect_to authorities_url }
      format.xml  { head :ok }
    end
  end

  def find_authority
    @authority = Authority.find( params[:id] )
  end

  private :find_authority
end