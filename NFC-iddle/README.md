Basic Mifare Classic 1k Card Reader and Writer
==============================================

Key
-------------------
1. Key are required for read and write operation.
2. Custom key can be loaded from external file, the key file should be just line-by-line txt file with 6bytes string per-line 
starting from sector-0 key.
3. If the key are not supplied default key "a0a1a2a3a4a5" will be used for I/O operation on all sector

Read
-------------------
1. Just tap your Mifare Card on the sensor and the apps will begin reading.
2. Do not remove the card untill you see the Data Dump is shown on screen.

Write
-------------------
1. Error Checking are not implemented , you are strong encouraged to only enter 16 byte hex per line. 
1. Writing on sector 0 is not possible
2. Do not try to modify the access condition on each block as it may brick your card.

Emulation(Not Implemented)
-------------------
1. Root priviledge are required for this to work.
2. You must insert your self sign cerificate for the apps to access secure element.
	keytool -exportcert -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android|xxd -p -|tr -d '\n'
3. Insert the key string to /etc/nfcee_access.xml.
	<signer android:signature="308 ..key... " >
	This will allow all app generated on your eclipse to access Secure Element.
4. The function are implemented partially but not working.Its only included for those who are interested for Card Emulation
