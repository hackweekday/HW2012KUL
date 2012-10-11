package com.mmu.nfciddle;

import java.io.IOException;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentFilter.MalformedMimeTypeException;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.MifareClassic;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

public class WriteActivity extends Activity {

	private static NfcAdapter mAdapter;
	private static PendingIntent mPendingIntent;
	private static IntentFilter[] mFilters;
	private static String[][] mTechLists;
	private static String []key;
	private EditText [] writeField;
	private TextView [] sector;
	
	private static final byte[] HEX_CHAR_TABLE = { (byte) '0', (byte) '1',
		(byte) '2', (byte) '3', (byte) '4', (byte) '5', (byte) '6',
		(byte) '7', (byte) '8', (byte) '9', (byte) 'A', (byte) 'B',
		(byte) 'C', (byte) 'D', (byte) 'E', (byte) 'F' };
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_write);
     
		Intent intent = getIntent();
		key = intent.getStringArrayExtra("strings");
		if( key == null)
			initKey();
		registerIntent();
		initView();
    }
    
    public void registerIntent(){
    	Log.i("INT","register Intent");
        mAdapter = NfcAdapter.getDefaultAdapter(this);
        mPendingIntent = PendingIntent.getActivity(this, 0, new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 0);
		IntentFilter ndef = new IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED);
		try {
			ndef.addDataType("*/*");
		} catch (MalformedMimeTypeException e) {
			throw new RuntimeException("fail", e);
		}
		mFilters = new IntentFilter[] { ndef, };
		mTechLists = new String[][] { new String[] { MifareClassic.class.getName() } };
    }
    private void resolveIntent(Intent intent) {
  		String action = intent.getAction();
  		Log.i("RSLINT","get intent");
  		if (NfcAdapter.ACTION_TECH_DISCOVERED.equals(action)) {
  			Log.i("resolveIntent","Discovered tag with intent: " + intent);
  			Tag tagFromIntent = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
  			MifareClassic mfc = MifareClassic.get(tagFromIntent);
  			
  			try{
  				mfc.connect();
  			}
  			catch (IOException e) {
	  			Log.e("resolveIntent", e.getLocalizedMessage());
	  		}

		  	boolean auth = false;
		  	
		  	for(int sector=0; sector< mfc.getSectorCount() ;sector++){
		  		try{
		  			Log.i("resolveIntent","Authentication on Sector:"+sector+" with key:"+key[sector]);
		  			auth = mfc.authenticateSectorWithKeyA(sector,asBytes(key[sector]));
		  			if (auth) {
		  				//insertTable("Sector: "+sector);
		  				for(int block= mfc.sectorToBlock(sector); block < mfc.sectorToBlock(sector)+mfc.getBlockCountInSector(sector); block++){
		  					if(writeField[block].getText() != null){
		  						Log.i("WRITE","MSG: "+writeField[block].getText().toString());
		  						mfc.writeBlock(block,asBytes(writeField[block].getText().toString()));
		  					}
		  				}
		  			} else {
		  				Log.e("resolveIntent","Authentication Failure");
		  				//insertTable("Authentication Fail on Sector: "+sector);
		  			}
		  		}catch (IOException e) {
		  			Log.e("resolveIntent", e.getLocalizedMessage());
		  		}
		  	}
  		}
  		AlertDialog.Builder alertbox = new AlertDialog.Builder(this);
  		alertbox.setMessage("Write Complete");
  		alertbox.show();
  	}
    
	public static String getHexString(byte[] raw, int len) {
		byte[] hex = new byte[2 * len];
		int index = 0;
		int pos = 0;

		for (byte b : raw) {
			if (pos >= len)
				break;

			pos++;
			int v = b & 0xFF;
			hex[index++] = HEX_CHAR_TABLE[v >>> 4];
			hex[index++] = HEX_CHAR_TABLE[v & 0xF];
		}

		return new String(hex);
	}
	
	public void onNewIntent(Intent intent) {
		Log.i("onNewIntent Read", "Discovered tag with intent: " + intent);
		resolveIntent(intent);
	}

    public static byte[] asBytes (String s) {
        String s2;
        byte[] b = new byte[s.length() / 2];
        int i;
        for (i = 0; i < s.length() / 2; i++) {
            s2 = s.substring(i * 2, i * 2 + 2);
            b[i] = (byte)(Integer.parseInt(s2, 16) & 0xff);
        }
        return b;
    }
    
    @Override
    public void onPause() {
        super.onPause();
        if (mAdapter != null) mAdapter.disableForegroundDispatch(this);
    }
    
    @Override
    public void onResume() {
        super.onResume();
        if (mAdapter != null) mAdapter.enableForegroundDispatch(this, mPendingIntent, mFilters,
                mTechLists);
    }
    
    public void initView(){
    	LinearLayout writelay = (LinearLayout) findViewById(R.id.writeLay);
    	//clear screen
    	if(writelay.getChildCount() > 0) 
    		writelay.removeAllViews(); 
    	
    	Button btn = new Button(this);
    	btn.setText("Write");
    	btn.setOnClickListener(new Button.OnClickListener() {
    	    public void onClick(View v) {
    	    	alert();
    	    }
    	});
    	
    	writelay.addView(btn);
		writeField = new EditText[64];
		sector = new TextView[16];
		
    	for(int i=0; i<16 ; i++){
    		sector[i] = new TextView(this);
    		sector[i].setText("Sector "+i);
    		writelay.addView(sector[i]);
	    	for(int j=0 ; j < 4 ;j++ ){
	    		writeField[(4*i)+j] = new EditText(this);
	    		try{
			    	if(ReadActivity.cardData[(4*i)+j] == null)
			    		writeField[(4*i)+j].setEnabled(false);
			    	else
			    		writeField[(4*i)+j].setText(ReadActivity.cardData[(4*i)+j]);
	    		}catch(Exception e){
	    			writeField[(4*i)+j].setText("");
	    		}
	    		writelay.addView(writeField[(4*i)+j]);
	    	}
    	}
    }
    
    public void alert(){
		AlertDialog.Builder alertbox = new AlertDialog.Builder(this);
		alertbox.setMessage("Tap Your Card For Write");
		alertbox.setPositiveButton("OK", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface arg0, int arg1) {
				registerIntent();
			}
		});
		alertbox.show();
    }
    
    private void initKey(){
    	key = new String[16];
    	for(int i=0 ; i < 16 ; i++)
    		key[i] = "a0a1a2a3a4a5";
    }
}
