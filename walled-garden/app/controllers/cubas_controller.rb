class CubasController < ApplicationController
  # GET /cubas
  # GET /cubas.json
  def index
    @cubas = Cuba.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cubas }
    end
  end

  # GET /cubas/1
  # GET /cubas/1.json
  def show
    @cuba = Cuba.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cuba }
    end
  end

  # GET /cubas/new
  # GET /cubas/new.json
  def new
    @cuba = Cuba.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cuba }
    end
  end

  # GET /cubas/1/edit
  def edit
    @cuba = Cuba.find(params[:id])
  end

  # POST /cubas
  # POST /cubas.json
  def create
    @cuba = Cuba.new(params[:cuba])

    respond_to do |format|
      if @cuba.save
        format.html { redirect_to @cuba, notice: 'Cuba was successfully created.' }
        format.json { render json: @cuba, status: :created, location: @cuba }
      else
        format.html { render action: "new" }
        format.json { render json: @cuba.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cubas/1
  # PUT /cubas/1.json
  def update
    @cuba = Cuba.find(params[:id])

    respond_to do |format|
      if @cuba.update_attributes(params[:cuba])
        format.html { redirect_to @cuba, notice: 'Cuba was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cuba.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cubas/1
  # DELETE /cubas/1.json
  def destroy
    @cuba = Cuba.find(params[:id])
    @cuba.destroy

    respond_to do |format|
      format.html { redirect_to cubas_url }
      format.json { head :no_content }
    end
  end
end
