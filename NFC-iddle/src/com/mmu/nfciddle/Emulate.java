package com.mmu.nfciddle;


import static com.mmu.nfciddle.Hex.fromHex;

import java.util.Collection;
import java.util.List;

//import com.mmu.nfciddle.CPLC;
//import com.mmu.nfciddle.GPCommands;
//import com.mmu.nfciddle.KeyInfo;
//import com.mmu.nfciddle.MifareManagerCommands;
import com.mmu.nfciddle.R;
//import com.mmu.nfciddle.SEEMVSession;
//import com.mmu.nfciddle.SecurityDomainFCI;
//import com.mmu.nfciddle.WalletControllerCommands;
//import com.mmu.nfciddle.WalletControllerFCI;

import com.mmu.nfciddle.SETerminal;

import sasc.emv.EMVApplication;
import sasc.emv.EMVCard;
import sasc.emv.EMVUtil;
import sasc.emv.SW;
import sasc.iso7816.AID;
import sasc.iso7816.BERTLV;
import sasc.terminal.CardConnection;
import sasc.terminal.CardResponse;
import sasc.terminal.Terminal;
import sasc.terminal.TerminalException;
import sasc.util.Util;
import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.Toast;

public class Emulate extends Activity {
	private static final String TAG = Emulate.class.getSimpleName();
    private Terminal terminal;
    private CardConnection seConn;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_emulate);
        Log.i("EMULATE","started");
        terminal = new SETerminal(getApplication());
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        closeSeSilently();
    }
    
    private void closeSeSilently() {
        if (seConn != null) {
            try {
                seConn.disconnect(false);
            } catch (TerminalException e) {
                Log.w(TAG, "Eror closing SE: " + e.getMessage(), e);
            }
        }
    }
    
    @Override
    public void onStart() {
    	Log.i(TAG, "onStart");
        super.onStart();
        try {
            seConn = terminal.connect();
            Log.i(TAG,"seConn connected");
        } catch (TerminalException e) {
            String message = "Failed to open SE: " + e.getMessage();
            Log.w(TAG, message, e);
            Toast.makeText(this, message, Toast.LENGTH_LONG).show();
            seConn = null;
            finish();
        }
    }
    
    @Override
    public void onStop() {
        super.onStop();

        closeSeSilently();
        seConn = null;
    }
    
    public void begin(View v) {
    	Log.i(TAG,"Emulation begin");
    	try {
    		byte [] response = ((SEConnection)seConn).sendApdu(fromHex("00A4040000"));
            
        } catch (Exception e) {
            Log.e(TAG, "Begin Error: " + e.getMessage());
        }
    }

    private CardResponse transmit(byte[] command, String description)
            throws TerminalException {
        Log.d(TAG, description);
        CardResponse response = seConn.transmit(command);
        //EMVUtil.printResponse(response, true);

        return response;
    }

    private String getEmvCardDisplayString(EMVCard card) {
        StringBuilder buff = new StringBuilder();
        int indent = 2;

        if (card.getApplications().isEmpty()) {
            buff.append("Google Wallet not installed or locked. Install and unlock Wallet and try again.");
            buff.append("\n");
            // PPSE in fact
            if (card.getPSE() != null) {
                buff.append("\n");
                buff.append("PPSE: ");
                buff.append("\n");
                buff.append(Util.getSpaces(indent) + card.getPSE().toString());

                return buff.toString();
            }
        }

        buff.append((Util.getSpaces(indent) + "EMV applications on SE"));
        buff.append("\n\n");
        buff.append(Util.getSpaces(indent + 2 * indent) + "Applications ("
                + card.getApplications().size() + " found):");
        buff.append("\n");
        for (EMVApplication app : card.getApplications()) {
            buff.append(Util.getSpaces(indent + 3 * indent) + app.toString());
        }

        if (card.getMasterFile() != null) {
            buff.append(Util.getSpaces(indent + indent) + "MF: "
                    + card.getMasterFile());
        }

        buff.append("------------------------------------------------------");
        buff.append("Extra info (if any)");
      //  buff.append(Util.getSpaces(indent) + "ATR: " + card.getATR());
      //  buff.append(Util.getSpaces(indent + indent) + "Interface Type: "+ card.getType());
        buff.append("\n");


        if (!card.getUnhandledRecords().isEmpty()) {
            buff.append(Util.getSpaces(indent + indent)
                    + "UNHANDLED GLOBAL RECORDS ("
                    + card.getUnhandledRecords().size() + " found):");

            for (BERTLV tlv : card.getUnhandledRecords()) {
                buff.append(Util.getSpaces(indent + 2 * indent) + tlv.getTag()
                        + " " + tlv);
            }
        }
        buff.append("\n");

        return buff.toString();
    }

}
