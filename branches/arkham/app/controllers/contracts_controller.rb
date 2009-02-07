class ContractsController < ApplicationController
  before_filter :find_contract, :only => %w( edit show update destroy )
  
  # GET /contracts
  # GET /contracts.xml
  def index
    @contracts = Contract.find( :all )

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contracts.to_xml }
    end
  end

  # GET /contracts/1
  # GET /contracts/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @contract.to_xml }
    end
  end

  # GET /contracts/new
  def new
    @contract = Contract.new
  end

  # GET /contracts/1;edit
  def edit
  end

  # POST /contracts
  # POST /contracts.xml
  def create
    @contract = Contract.new( params[:contract] )

    respond_to do |format|
      if @contract.save
        flash[:notice] = 'Contract was successfully created.'
        format.html { redirect_to contract_url(@contract) }
        format.xml  { head :created, :location => contract_url(@contract) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contract.errors.to_xml }
      end
    end
  end

  # PUT /contracts/1
  # PUT /contracts/1.xml
  def update
    respond_to do |format|
      if @contract.update_attributes( params[:contract] )
        flash[:notice] = 'Contract was successfully updated.'
        format.html { redirect_to contract_url(@contract) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contract.errors.to_xml }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.xml
  def destroy
    @contract.destroy

    respond_to do |format|
      format.html { redirect_to contracts_url }
      format.xml  { head :ok }
    end
  end

  def find_contract
    @contract = Contract.find( params[:id] )
  end

  private :find_contract
end
