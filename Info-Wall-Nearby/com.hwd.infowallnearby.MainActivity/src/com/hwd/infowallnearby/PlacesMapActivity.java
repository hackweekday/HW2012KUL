package com.hwd.infowallnearby;

import java.util.List;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;

public class PlacesMapActivity extends MapActivity {
	// Nearest places
	PlacesList nearPlaces;

	// Map view
	MapView mapView;

	// Map overlay items
	List<Overlay> mapOverlays;

	AddItemizedOverlay itemizedOverlay;

	GeoPoint geoPoint;
	// Map controllers
	MapController mc;
	
	double latitude;
	double longitude;
	OverlayItem overlayitem;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.map_places);

		// Getting intent data
		Intent i = getIntent();
		
		// Users current geo location
		String user_latitude = i.getStringExtra("user_latitude");
		String user_longitude = i.getStringExtra("user_longitude");
		
		// Nearplaces list
		nearPlaces = (PlacesList) i.getSerializableExtra("near_places");

		mapView = (MapView) findViewById(R.id.mapView);
		mapView.setBuiltInZoomControls(true);

		mapOverlays = mapView.getOverlays();
		
		// Geopoint to place on map
		geoPoint = new GeoPoint((int) (Double.parseDouble(user_latitude) * 1E6),
				(int) (Double.parseDouble(user_longitude) * 1E6));
		
		// Drawable marker icon
		Drawable drawable_user = this.getResources()
				.getDrawable(R.drawable.mark_red);
		
		itemizedOverlay = new AddItemizedOverlay(drawable_user, this);
		
		// Map overlay item
		overlayitem = new OverlayItem(geoPoint, "Your Location",
				"That is you!");

		itemizedOverlay.addOverlay(overlayitem);
		
		mapOverlays.add(itemizedOverlay);
		itemizedOverlay.populateNow();
		
		// Drawable marker icon
		Drawable drawable = this.getResources()
				.getDrawable(R.drawable.mark_blue);
		
		itemizedOverlay = new AddItemizedOverlay(drawable, this);

		mc = mapView.getController();

		// These values are used to get map boundary area
		// The area where you can see all the markers on screen
		int minLat = Integer.MAX_VALUE;
		int minLong = Integer.MAX_VALUE;
		int maxLat = Integer.MIN_VALUE;
		int maxLong = Integer.MIN_VALUE;

		// check for null in case it is null
		if (nearPlaces.results != null) {
			// loop through all the places
			for (Place place : nearPlaces.results) {
				latitude = place.geometry.location.lat; // latitude
				longitude = place.geometry.location.lng; // longitude
				
				// Geopoint to place on map
				geoPoint = new GeoPoint((int) (latitude * 1E6),
						(int) (longitude * 1E6));
				
				// Map overlay item
				overlayitem = new OverlayItem(geoPoint, place.name,
						place.vicinity);

				itemizedOverlay.addOverlay(overlayitem);
				
				
				// calculating map boundary area
				minLat  = (int) Math.min( geoPoint.getLatitudeE6(), minLat );
			    minLong = (int) Math.min( geoPoint.getLongitudeE6(), minLong);
			    maxLat  = (int) Math.max( geoPoint.getLatitudeE6(), maxLat );
			    maxLong = (int) Math.max( geoPoint.getLongitudeE6(), maxLong );
			}
			mapOverlays.add(itemizedOverlay);
			
			// showing all overlay items
			itemizedOverlay.populateNow();
		}
		
		// Adjusting the zoom level so that you can see all the markers on map
		mapView.getController().zoomToSpan(Math.abs( minLat - maxLat ), Math.abs( minLong - maxLong ));
		
		// Showing the center of the map
		mc.animateTo(new GeoPoint((maxLat + minLat)/2, (maxLong + minLong)/2 ));
		mapView.postInvalidate();

	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}

}
