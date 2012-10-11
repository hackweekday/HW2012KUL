package com.hwd.infowallnearby;

import org.alexd.jsonrpc.JSONRPCClient;
import org.alexd.jsonrpc.JSONRPCException;
import org.alexd.jsonrpc.JSONRPCParams;
import org.json.JSONArray;

public class RPC {
	String srvuri = "";
	JSONRPCClient client;
	public RPC()
	{
		srvuri="http://10.0.2.2:8000/iwn/service/call/jsonrpc";
		client = JSONRPCClient.create(srvuri, JSONRPCParams.Versions.VERSION_2);
        client.setConnectionTimeout(2000);
        client.setSoTimeout(2000);
	}
	
	public JSONArray getPosts(String placename,String lat, String lng){
		
		try{
        	//result = client.callString("get_posts","12345");        
        	return client.callJSONArray("get_posts",placename,lat,lng);
        }catch(JSONRPCException e){
        	e.printStackTrace();   
        	return new JSONArray();
        }
		
	}
	
	public String sendPost(String txt, String username,String placename, String lat, String lng){
		try{
			return client.callString("write_post",txt, username,placename, lat, lng);	
		}catch(JSONRPCException e){
			return "Error in sending post";
		}
	}
	
	
}
