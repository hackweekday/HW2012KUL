import datetime
import logging

from pyramid.httpexceptions import HTTPNotFound

from qrevent import models, modules

log = logging.getLogger(__name__)

def api_include(config):
    config.add_route('api.identify', '/api/identify')

    config.add_view(API, attr='validate',
                    route_name='api.identify',
                    renderer='jsonp')
    
class Origin(object):
    def __init__(self, request):
        self.request = request
        self.session = models.DBSession()
        self.check_access()

    def validate_submission(self, *args):
        p = self.request.params
        for field in args:
            if not p.get(field):
                raise Exception('Mandatory field "%s" is not found.')

    def check_access(self):
        # Implement hmac stuffs here
        pass

class API(Origin):
    def validate(self):
        try:
            self.validate_submission('qr')
        except Exception as e:
            log.error(e)
            raise e
        p = self.request.params
        qr = p.get('qr')
        analyse = modules.QRAnalyse(qr)
        resp = analyse.response(**self.request.registry.settings)
        return resp

class CallTwitter(object):
    pass

class CallQnack(object):
    pass
