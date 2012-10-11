package com.mmu.nfciddle;

import java.io.IOException;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentFilter.MalformedMimeTypeException;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.MifareClassic;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

public class ReadActivity extends Activity {
	private static NfcAdapter mAdapter;
	private static PendingIntent mPendingIntent;
	private static IntentFilter[] mFilters;
	private static String[][] mTechLists;
	private static String []key;
	private TableRow dummy;
	private static TableLayout layout;
	public static String [] cardData;
	// I need this for write_activity to access the data dump
	// need-to-fix
	
	private static final byte[] HEX_CHAR_TABLE = { (byte) '0', (byte) '1',
		(byte) '2', (byte) '3', (byte) '4', (byte) '5', (byte) '6',
		(byte) '7', (byte) '8', (byte) '9', (byte) 'A', (byte) 'B',
		(byte) 'C', (byte) 'D', (byte) 'E', (byte) 'F' };
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_read);
        layout = (TableLayout)findViewById(R.id.dumpTable);
        dummy = new TableRow(this);
        cardData = new String[64];
        dummy.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.FILL_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
        mAdapter = NfcAdapter.getDefaultAdapter(this);
        mPendingIntent = PendingIntent.getActivity(this, 0, new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 0);
		IntentFilter ndef = new IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED);
		
		Intent intent = getIntent();
		key = intent.getStringArrayExtra("strings");
		if( key == null)
			initKey();
		
		try {
			ndef.addDataType("*/*");
		} catch (MalformedMimeTypeException e) {
			throw new RuntimeException("fail", e);
		}
		
		mFilters = new IntentFilter[] { ndef, };
		mTechLists = new String[][] { new String[] { MifareClassic.class.getName() } };
    }
    
    private void resolveIntent(Intent intent) {
    	TextView t = (TextView)findViewById(R.id.tap);
    	t.setVisibility(View.GONE);
        layout.removeAllViewsInLayout();
        
  		String action = intent.getAction();
  		if (NfcAdapter.ACTION_TECH_DISCOVERED.equals(action)) {
  			Log.i("resolveIntent","Discovered tag with intent: " + intent);
  			Tag tagFromIntent = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
  			MifareClassic mfc = MifareClassic.get(tagFromIntent);
  			byte[] data;
  			
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
		  			insertTable("Sector: "+sector);
		  			if (auth) {
		  				for(int block= mfc.sectorToBlock(sector); block < mfc.sectorToBlock(sector)+mfc.getBlockCountInSector(sector); block++){
				  			data = mfc.readBlock(block);
		  					cardData[block] = getHexString(data, data.length);
		  					
			  				if (cardData != null) {						
			  					Log.i("resolveIntent",sector+" B"+block+":"+cardData[block]);
			  					insertTable(""+cardData[block]);
			  				} else {
			  					Log.e("resolveIntent","Data Read failed");
			  					cardData[block] = null;
			  					insertTable("Data Read Fail");
			  				}
		  				}
		  			} else {
		  				Log.e("resolveIntent","Authentication Failure");
		  				for(int block= mfc.sectorToBlock(sector); block < mfc.sectorToBlock(sector)+mfc.getBlockCountInSector(sector); block++){
			  				cardData[block] = null;
			  				insertTable("Authentication Fail on Block: "+block);
		  				}
		  			}
		  		}catch (IOException e) {
		  			Log.e("resolveIntent", e.getLocalizedMessage());
		  		}
		  	}
  		}
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
	
	public void insertTable(String s){
		TextView t = new TextView(this);
		t.setText(s);
		dummy = new TableRow(this);
	    dummy.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.FILL_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
		dummy.addView(t);
	    layout.addView(dummy ,new TableLayout.LayoutParams(TableLayout.LayoutParams.FILL_PARENT, TableLayout.LayoutParams.WRAP_CONTENT));
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
    
    private void initKey(){
    	key = new String[16];
    	for(int i=0 ; i < 16 ; i++)
    		key[i] = "a0a1a2a3a4a5";
    }
}
