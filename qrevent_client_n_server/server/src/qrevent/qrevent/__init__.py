from pyramid.config import Configurator
from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.renderers import JSONP

from pyramid_beaker import session_factory_from_settings

from qrevent import models, security

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    db = models.DBConnect(**settings)
    db.connect()

    # A very simple default Authentication Policy
    authn_policy = AuthTktAuthenticationPolicy('somesecret',
                                               callback=security.groupfinder)
    # A very simple default ACL Authorization Policy
    authz_policy = ACLAuthorizationPolicy()

    # Setting up the config settings to the application config
    config = Configurator(settings=settings,
                          root_factory='qrevent.security.RootFactory',
                          authentication_policy=authn_policy,
                          authorization_policy=authz_policy)
    
    config.add_renderer('jsonp', JSONP(param_name='callback'))

    # Setup pyramid_beaker as session factory
    session_factory = session_factory_from_settings(settings)

    # Set session factory to the pyramid_beaker session factory
    config.set_session_factory(session_factory)

    config.add_static_view('static', 'qrevent:static')

    config.include('qrevent.api.api_include')
    config.include('qrevent.web.web_include')

    return config.make_wsgi_app()

