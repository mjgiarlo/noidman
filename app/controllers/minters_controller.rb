class MintersController < ApplicationController
  # GET /minters
  # GET /minters.xml
  def index
    authority = Authority.find( params[:authority_id] )
    @minters = authority.minters.find(:all)

    respond_to do |format|
      format.html # default
      format.xml  { render :xml => @minters.to_xml }
    end
  end

  # GET /minters/1
  # GET /minters/1.xml
  def show
    @minter = Minter.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @minter.to_xml }
    end
  end

  # GET /minters/new
  def new
    @minter = Minter.new
  end

  # GET /minters/1;edit
  def edit
    @minter = Minter.find(params[:id])
  end

  # POST /minters
  # POST /minters.xml
  def create
    @minter = Minter.new(params[:minter])

    respond_to do |format|
      if @minter.save
        flash[:notice] = 'Minter was successfully created.'
        format.html { redirect_to minter_url(@minter) }
        format.xml  { head :created, :location => minter_url(@minter) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @minter.errors.to_xml }
      end
    end
  end

  # PUT /minters/1
  # PUT /minters/1.xml
  def update
    @minter = Minter.find(params[:id])

    respond_to do |format|
      if @minter.update_attributes(params[:minter])
        flash[:notice] = 'Minter was successfully updated.'
        format.html { redirect_to minter_url(@minter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @minter.errors.to_xml }
      end
    end
  end

  # DELETE /minters/1
  # DELETE /minters/1.xml
  def destroy
    @minter = Minter.find(params[:id])
    @minter.destroy

    respond_to do |format|
      format.html { redirect_to minters_url }
      format.xml  { head :ok }
    end
  end
end
