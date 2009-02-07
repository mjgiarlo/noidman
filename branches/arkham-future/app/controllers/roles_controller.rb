class RolesController < ApplicationController
  # GET /roles
  # GET /roles.xml
  def index
    finder = case
             when params[:minter_id]: Minter.find( params[:minter_id] )
             when params[:authority_id]: Authority.find( params[:authority_id] )
             else ''
             end
    @roles = finder.empty? ? Role.find(:all) : finder.roles.find( :all ) 

    respond_to do |format|
      format.html # default
      format.xml  { render :xml => @roles.to_xml }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @role.to_xml }
    end
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1;edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to role_url(@role) }
        format.xml  { head :created, :location => role_url(@role) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors.to_xml }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to role_url(@role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors.to_xml }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to roles_url }
      format.xml  { head :ok }
    end
  end
end
