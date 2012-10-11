# coding: utf8
# try something like
import md5;

def index():
    return "Not implemented yet"

def call():
    """
    exposes services. for example:
    http://..../[app]/default/call/jsonrpc
    decorate with @services.jsonrpc the functions to expose
    supports xml, json, xmlrpc, jsonrpc, amfrpc, rss, csv
    """
    return service()

@service.jsonrpc
def get_posts(placename,lat,lng):
    '''Get the posts in each wall'''
    db.select()
    r = [{"msg":"message 1"},{"msg":"message 2"},{"msg":"message 3"},{"msg":"message 4"}]
    return r

@service.jsonrpc
def write_post(txt,user,placename,lat,lng):
    """ Write post to the wall """
       
    placehash = md5.new(placename+lat+lng).digest();
    db.posts.insert(post=txt, placehash=placehash,crby=1)
    return True

@service.jsonrpc
def check_in(user,pname,lat,lng):
    """ Check in to the place """
    place_hash =""
    return place_hash



