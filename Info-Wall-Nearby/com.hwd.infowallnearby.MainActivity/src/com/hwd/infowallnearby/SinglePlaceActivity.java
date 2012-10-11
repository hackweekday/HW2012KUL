package com.hwd.infowallnearby;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;


import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

public class SinglePlaceActivity extends Activity implements OnClickListener {
	// flag for Internet connection status
	Boolean isInternetPresent = false;

	// Connection detector class
	ConnectionDetector cd;
	
	// Alert Dialog Manager
	AlertDialogManager alert = new AlertDialogManager();

	// Google Places
	GooglePlaces googlePlaces;
	
	// Place Details
	PlaceDetails placeDetails;
	
	// Progress dialog
	ProgressDialog pDialog;
	
	// KEY Strings
	public static String KEY_REFERENCE = "reference"; // id of the place
	
	private List<JSONObject> chatLog_ = new ArrayList<JSONObject>(10);
	private ListView chatView_;
	private ArrayAdapter chatViewAdapter_;		
	Handler lHandler;
	RPC rpc = new RPC();
	
	private String cpName; //current place name
	private String cpLat; //current place latitude
	private String cpLng; //current place longitude
	
	Button btnpost; 
	EditText txtChatMessage;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.single_place);
		
		Intent i = getIntent();
		
		// Place referece id
		String reference = i.getStringExtra(KEY_REFERENCE);
		
		// Calling a Async Background thread
		new LoadSinglePlaceDetails().execute(reference);
		
		btnpost = (Button)findViewById(R.id.sendMessageButton);
		btnpost.setOnClickListener(this);
		
		txtChatMessage = (EditText)findViewById(R.id.chatMessage);
		
		
		lHandler = new Handler(){
			@Override
			public void handleMessage(Message msg){				
				chatView_ = (ListView) findViewById(R.id.chatView);		
    			chatViewAdapter_ = new com.hwd.infowallnearby.ChatListAdapter(SinglePlaceActivity.this, android.R.id.text1, chatLog_);
    			chatView_.setAdapter(chatViewAdapter_);
			}
		};
		
		
	}
	
	public void loadPosts(final String placename,final String lat,final String lng){
		//this.cpName = this.cpName != null? placename: this.cpName;
		//this.cpLat = this.cpLat != null? placename: this.cpLat;
		//this.cpLng = this.cpLng != null? placename: this.cpLng;
		this.cpName = placename;
		this.cpLat = lat;
		this.cpLng = lng;
		
		new Thread(
			new Runnable()
	    	{
	    	    public void run() 
	    	    {
	    	    	JSONArray posts = rpc.getPosts(placename,lat,lng);
	    	    	for(int j=0; j<posts.length(); j++){
	    	    		try{
	    	    			chatLog_.add(posts.getJSONObject(j));
	    	    			
	    	    		}
	    	    		catch(JSONException jsonex) {
	    	    			System.out.println(jsonex.getMessage());
	    	    		}
	    	    		lHandler.sendMessage(new Message());
	    	    	}    			
	    	    }
	    }).start();		
	}
	
	
	/**
	 * Background Async Task to Load Google places
	 * */
	class LoadSinglePlaceDetails extends AsyncTask<String, String, String> {

		/**
		 * Before starting background thread Show Progress Dialog
		 * */
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			pDialog = new ProgressDialog(SinglePlaceActivity.this);
			pDialog.setMessage("Loading profile ...");
			pDialog.setIndeterminate(false);
			pDialog.setCancelable(false);
			pDialog.show();
			
		}

		/**
		 * getting Profile JSON
		 * */
		protected String doInBackground(String... args) {
			String reference = args[0];
			
			// creating Places class object
			googlePlaces = new GooglePlaces();

			// Check if used is connected to Internet
			try {
				placeDetails = googlePlaces.getPlaceDetails(reference);

			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		/**
		 * After completing background task Dismiss the progress dialog
		 * **/
		protected void onPostExecute(String file_url) {
			// dismiss the dialog after getting all products
			pDialog.dismiss();
			// updating UI from Background Thread
			runOnUiThread(new Runnable() {
				public void run() {
					/**
					 * Updating parsed Places into LISTVIEW
					 * */
					if(placeDetails != null){
						String status = placeDetails.status;
						
						// check place deatils status
						// Check for all possible status
						if(status.equals("OK")){
							if (placeDetails.result != null) {
								String name = placeDetails.result.name;
								String address = placeDetails.result.formatted_address;
								String phone = placeDetails.result.formatted_phone_number;
								String latitude = Double.toString(placeDetails.result.geometry.location.lat);
								String longitude = Double.toString(placeDetails.result.geometry.location.lng);
								
								Log.d("Place ", name + address + phone + latitude + longitude);
								
								// Displaying all the details in the view
								// single_place.xml
								TextView lbl_name = (TextView) findViewById(R.id.name);
								//TextView lbl_address = (TextView) findViewById(R.id.address);
								//TextView lbl_phone = (TextView) findViewById(R.id.phone);
								//TextView lbl_location = (TextView) findViewById(R.id.location);
								
								// Check for null data from google
								// Sometimes place details might missing
								name = name == null ? "Not present" : name; // if name is null display as "Not present"
								address = address == null ? "Not present" : address;
								phone = phone == null ? "Not present" : phone;
								latitude = latitude == null ? "Not present" : latitude;
								longitude = longitude == null ? "Not present" : longitude;
								
								lbl_name.setText(name);
								//lbl_address.setText(address);
								//lbl_phone.setText(Html.fromHtml("<b>Phone:</b> " + phone));
								//lbl_location.setText(Html.fromHtml("<b>Latitude:</b> " + latitude + ", <b>Longitude:</b> " + longitude));
								
								
								//Get From Web2Py Server								
								loadPosts(name,latitude,longitude);
								
								
							}
						}
						else if(status.equals("ZERO_RESULTS")){
							alert.showAlertDialog(SinglePlaceActivity.this, "Near Places",
									"Sorry no place found.",
									false);
						}
						else if(status.equals("UNKNOWN_ERROR"))
						{
							alert.showAlertDialog(SinglePlaceActivity.this, "Places Error",
									"Sorry unknown error occured.",
									false);
						}
						else if(status.equals("OVER_QUERY_LIMIT"))
						{
							alert.showAlertDialog(SinglePlaceActivity.this, "Places Error",
									"Sorry query limit to google places is reached",
									false);
						}
						else if(status.equals("REQUEST_DENIED"))
						{
							alert.showAlertDialog(SinglePlaceActivity.this, "Places Error",
									"Sorry error occured. Request is denied",
									false);
						}
						else if(status.equals("INVALID_REQUEST"))
						{
							alert.showAlertDialog(SinglePlaceActivity.this, "Places Error",
									"Sorry error occured. Invalid Request",
									false);
						}
						else
						{
							alert.showAlertDialog(SinglePlaceActivity.this, "Places Error",
									"Sorry error occured.",
									false);
						}
					}else{
						alert.showAlertDialog(SinglePlaceActivity.this, "Places Error",
								"Sorry error occured.",
								false);
					}
					
					
				}
			});

		}

	}


	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		final String txt = txtChatMessage.getText().toString();
		//TODO: Validation and SPAM control here		
		
		new Thread(
				new Runnable()
		    	{
		    	    public void run() 
		    	    {
		    	    	String result = rpc.sendPost(txt,"unregistered",cpName,cpLat, cpLng);		    	    			
		    	    }
		    }).start();
	}

}
