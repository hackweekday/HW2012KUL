from pyramid import httpexceptions
from pyramid.renderers import render_to_response

def api_error_include(config):
    config.add_view(api_error,
                    context=Exception,
                    renderer='json')
    config.add_view(api_error,
                    context='pyramid.httpexceptions.HTTPError',
                    renderer='json')

def api_error(request):
    if isinstance(request.exception, httpexceptions.HTTPError):
        message = request.exception.status
        status_int = request.exception.status_int
    else:
        exception = httpexceptions.HTTPNotFound()
        message = exception.status
        status_int = exception.status_int
    params = {'code':status_int,
              'message':message}
    response = render_to_response('json', params, request=request)
    response.status_int = status_int
    return response

def web_error_include(config):
    config.add_view(web_error,
                    context=Exception,
                    renderer='qrevent:templates/error.pt')
    config.add_view(web_error,
                    context='pyramid.httpexceptions.HTTPError',
                    renderer='qrevent:templates/error.pt')

def web_error(request):
    return {}
