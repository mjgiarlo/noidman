class IdentifiersController < ApplicationController
  # GET /identifiers
  # GET /identifiers.xml
  def index
    finder = case
             when params[:minter_id]: Minter.find( params[:minter_id] )
             when params[:user_id]: Authority.find( params[:user_id] )
             when params[:contract_id]: Contract.find( params[:contract_id] )
             end
    @identifiers = finder.identifiers.find(:all)

    respond_to do |format|
      format.html # default
      format.xml  { render :xml => @identifiers.to_xml }
      format.rss  { render :action => 'feed.rxml' }
    end
  end

  # GET /identifiers/1
  # GET /identifiers/1.xml
  def show
    @identifier = Identifier.find(params[:id])

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
    @identifier = Identifier.find(params[:id])
  end

  # POST /identifiers
  # POST /identifiers.xml
  def create
    @identifier = Identifier.new(params[:identifier])

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
    @identifier = Identifier.find(params[:id])

    respond_to do |format|
      if @identifier.update_attributes(params[:identifier])
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
    @identifier = Identifier.find(params[:id])
    @identifier.destroy

    respond_to do |format|
      format.html { redirect_to identifiers_url }
      format.xml  { head :ok }
    end
  end

  # GET /ark:/...
  def resolve
    # resolve an identifier and redirect to the URL
  end
end
