class Api::V1::AppliancesController < API::V1::ApplicationController
  
  before_filter :parse_body_json, only: :create

  def index
    @appliances = Appliance.all

    respond_with @appliances
  end

  def show
    @appliance = Appliance.find(params[:id])

    respond_with @appliance
  end

  def create
    @appliance = Appliance.new_through_api(@attributes['appliance'])
    @appliance.save()
    
    respond_with @appliance
  end

end