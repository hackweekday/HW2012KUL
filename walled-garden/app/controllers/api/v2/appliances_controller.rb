class Api::V2::AppliancesController < API::V2::ApplicationController

  def index
    @appliances = Appliance.all

    respond_with @appliances
  end

end