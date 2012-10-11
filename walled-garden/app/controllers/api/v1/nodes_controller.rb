class Api::V1::NodesController < API::V1::ApplicationController

  before_filter :parse_body_non_json, :only => [:create, :result]

  def index
    @nodes = Node.all
    respond_with @nodes
  end

  def show
    @node = Node.find(params[:id])
    respond_with @node
  end

  def create
    @attributes['node']['ip_address'] = get_ip
    @attributes['node']['node_name'] = get_ip
    @node = NodeApi.new_through_api(@attributes['node'])
    if @node.save
      #Akob: Maintain message.
      NodeMessage.create(:node_id => @node.id, 
      :message => t(:node_request, :node_serial => @node.node_serial, :remote_ip => get_ip), 
      :received_or_sent => true, :node_name => @node.node_name.nil? ? @node.id : @node.node_name)
      #Auto add IP into white list node_messages
      NodeAddress.create(:node_id => @node.id, :ip => get_ip)
    end
    respond_with @node, :location => nodes_url
  end

  def result
    node = @attributes['node']
    @attributes['node']['ip_address'] = get_ip
    @attributes['node']['node_name'] = get_ip
    id = @attributes['node']['id']
    @node = NodeApi.update_through_api(@attributes['node'])
    node_name = @attributes['node']['node_name']
    #@node.save
    #respond_with @node
    if node["status"] == 1
        NodeAddress.create(:node_id => id, :ip => get_ip)
        NodeMessage.create(:node_id => id, 
                           :message => t(:node_approved, :node_serial => node["node_serial"], :remote_ip => get_ip), 
                           :received_or_sent => true,
                           :node_name => node_name
                           )
    elsif node["status"] == 2
        NodeMessage.create(:node_id => id, 
                           :message => t(:node_rejected, :node_serial => node["node_serial"], :remote_ip => get_ip), 
                           :received_or_sent => true,
                           :node_name => node_name
                           )
    end
    render :json => {:status => :created}
  end

  #def update
  #  @node = NodeApi.update_through_api(@attributes['node'])
  #  respond_with @node, :location => nodes_url
  #end
end
