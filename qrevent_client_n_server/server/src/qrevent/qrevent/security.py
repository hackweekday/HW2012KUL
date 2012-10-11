"""Security module
"""
from pyramid.security import Allow

from qrevent import models

class RootFactory(object):
    """ACL for the whole site
    """
    __acl__ = [(Allow, 'user', 'user')]

    def __init__(self, request):
        pass

def groupfinder(userid, request):
    session = models.DBSession()
    user = (session.query(models.Account)
            .filter(models.Account.username==unicode(userid))
            .filter(models.Account.is_active==True)
            .first())
    if user:
        return ['user']
