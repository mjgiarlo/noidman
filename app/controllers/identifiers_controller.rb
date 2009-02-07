class IdentifiersController < ApplicationController
  before_filter :find_identifier, :only => %w( edit show update destroy )

  def resolve
    # resolve /ark:/ requests
    redirect_to Identifier.find_by_ark( params[:ark] ).url 
  end

  # GET /identifiers
  # GET /identifiers.xml
  # GET /identifiers.rss
  def index
    finder = if params[:authority_id]
               Authority.find( params[:authority_id] )
             elsif params[:contract_id]
               Contract.find( params[:contract_id] )
             elsif params[:user_id]
               User.find( params[:user_id] )
             else
               nil
             end
    @identifiers = finder.nil? ? Identifier.find( :all ) : finder.identifiers.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @identifiers.to_xml }
      format.rss  { render :action => 'feed.rxml', :layout => false } 
    end
  end

  # GET /identifiers/1
  # GET /identifiers/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @identifier.to_xml }
    end
  end

  # GET /identifiers/new
  def new
    @identifier = Identifier.new
  end

  # GET /identifiers/1;edit
  def edit
  end

  # POST /identifiers
  # POST /identifiers.xml
  def create
    @identifier = Identifier.new( params[:identifier] )

    respond_to do |format|
      if @identifier.save
        flash[:notice] = 'Identifier was successfully created.'
        format.html { redirect_to identifier_url(@identifier) }
        format.xml  { head :created, :location => identifier_url(@identifier) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @identifier.errors.to_xml }
      end
    end
  end

  # PUT /identifiers/1
  # PUT /identifiers/1.xml
  def update
    respond_to do |format|
      if @identifier.update_attributes( params[:identifier] )
        flash[:notice] = 'Identifier was successfully updated.'
        format.html { redirect_to identifier_url(@identifier) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @identifier.errors.to_xml }
      end
    end
  end

  # DELETE /identifiers/1
  # DELETE /identifiers/1.xml
  def destroy
    @identifier.destroy

    respond_to do |format|
      format.html { redirect_to identifiers_url }
      format.xml  { head :ok }
    end
  end

  def find_identifier
    @identifier = Identifier.find( params[:id] )
  end

  private :find_identifier
end
