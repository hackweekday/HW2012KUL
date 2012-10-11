class Api::V1::CheckController < API::V1::ApplicationController
	def index
		unless params[:node_serial].blank?
			n = Node.where(:node_serial => params[:node_serial]).first
			if n.nil?
				render :json => {:status => :ok}
			else
				render :json => {:status => :exist}
			end
		else
			render :json => {:status => :invalid}
		end
	end

	def validate_node
		n = Node.where(:node_serial => params[:node_serial]).first
		if n.nil?
			render :json => {:status => :nil}
		else
			if n.status == 1
				render :json => {:status => :ok}
			elsif n.status == 0
				render :json => {:status => :waiting_approval}
			else
				render :json => {:status => :error}
			end
		end
	end
end