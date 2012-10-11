import requests

from qrevent import models

class QRAnalyse(object):
    def __init__(self, qrcode):
        self.qrcode = qrcode

    def identify(self):
        if (self.qrcode.lower().startswith('http') or
            self.qrcode.lower().startswith('https')):
            return 'url'
        else:
            return 'text'

    def response(self, **settings):
        qrtype = self.identify()
        
        resp = self.verify()
        actions = []
        if qrtype == 'url':
            actions.extend(['surf', 'tweet'])
            if 'app.qnack.com/qr/' in self.qrcode:
                actions.append('qnack')
            else:
                apikey = settings['google.safebrowsing.key']
                client = settings['qrevent.client.name']
                client_ver = settings['qrevent.client.version']

                sb = SafeBrowsing(client=client,
                                  appver=client_ver,
                                  apikey=apikey,
                                  url=self.qrcode)
                resp['warning'] = not sb.is_safe()
        else:
            actions.append('read')
            if len(self.qrcode) <= 140:
                actions.append('tweet')

        resp['actions'] = actions
        return resp

    def verify(self):
        resp = {'issuer':'Unknown',
                'verified':False}

        session = models.DBSession()
        record = (session.query(models.QrCode)
                  .filter(models.QrCode.qrcode==self.qrcode)
                  .first())
        if record:
            resp['verified'] = True
            resp['issuer'] = record.issuer
        return resp            

class SafeBrowsing(object):
    def __init__(self, **data):
        self.data = data
        if not self.data.get('pver'):
            self.data['pver'] = '3.0'

        required_field = ['client', 'apikey', 'appver', 'url']
        map(self.check_required, required_field)

    def check_required(self, field):
        if not self.data.get(field):
            raise Exception('Required field "%s" is not found.' % field)

    def request(self):
        url = 'https://sb-ssl.google.com/safebrowsing/api/lookup'
        resp = requests.get(url, params=self.data)
        return resp

    def is_safe(self):
        resp = self.request()
        return resp.status_code == 204

class CallQnack(object):
    def __init__(self, username, password, qr):
        self.username = username
        self.password = password
        self.qr = qr

    
