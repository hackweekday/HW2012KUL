QREvents is an open framework to add value to QRCode scanning.

QRCode by itself may have content but prone to attacks/impersonation
and misdirection.  As a plain content, it may embed open standards but depends
on the clients' installed apps to process them.

QREvents is proposed to solve both problems of making QRCode scanning
safer and more productive.

After a QRCode scan event, the client submits a Web service call 
the QREvent server.

The QREvents server performs:

a) Cleansing
b) Validity and context check
c) Any followon processing specific to
   the setting of the user and to the context of the QRCode scan.
   
   
Using the IFTTT method, a series of post scan processing can be
done according to the context specified or indicated or detected
by the QREvents server.


a) Cleansing
Cleansing may be checking for phishing or attack sites from
public services like Google's safe browsing check or any
credible blacklist maintainer(s).

Cleansing may also be rewriting rules that cleans up the entry
from impersonation or typo hacks.

b) Validity and Context check
For each user, they may maintain their own rule sets (of
available rules shared by others) to allow or disallow QRCode
contents to be passed to the next execution phase - ie diverting
to /dev/null specific to themselves.

For example, if the user is more likely to scan luggage tags
the QRCode content pattern would be checked for the luggage tags
pattern or per context that the user sets active at that time.

c) Following processing
Depending on the pattern of QRCode content detected and already
cleanse/validate, it will be passed to the following execution
chain.  In our example of luggage tag, the luggage tag might be
uploaded to the database of "arrival" or "departing" luggage database
the handler just scanned.  A mobile or web base/desktop client is 
envisioned to be flexible.  It might also be tweeted to the
owner of the luggage which carosel the luggage is loaded upon
or if it has been boarded to the correct transport route.

Source Repository at Github
===========================
https://github.com/klrkdekira/qrevent_server

QREvent client demo source is available at
==========================================
https://github.com/klrkdekira/qrevent_client

How to install
==============
$ python bootstrap

$ bin/buildout

For development

$ bin/pserve src/qrevent/development.ini

For production

$ bin/pserve src/qrevent/production.ini

How to insert default data
==========================
After running buildout

$ bin/python -m qrevent.scripts.initdb src/qrevent/[development.ini|production.ini]

Credentials created

Default username and password
=============================
username: alphadude

password: helloworld

Default API access key and private key (For HMAC)
=================================================
Not used currently

access_key: 0c36ed7f5a

private_key: 28b33a01a3680090c58923e017f4a11a

