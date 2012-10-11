import logging

from pyramid.security import remember, forget
from pyramid.httpexceptions import HTTPFound, HTTPNotFound
from pyramid.renderers import get_renderer

from qrevent import models, forms

log = logging.getLogger(__name__)

PERMISSION = 'user'

def web_include(config):
    # config.include('web_error_include')
    config.include(account_include)
    config.include(record_include)
    
def account_include(config):
    config.add_route('login', '/login')
    config.add_view(Account, attr='login',
                    route_name='login',
                    renderer='qrevent:templates/login.pt')
    config.add_view(Account, attr='login',
                    context='pyramid.httpexceptions.HTTPForbidden',
                    renderer='qrevent:templates/login.pt')

    config.add_route('logout', '/logout')
    config.add_view(Account, attr='logout',
                    route_name='logout')
    
class Account(object):
    def __init__(self, request):
        self.request = request
        self.session = models.DBSession()
        self.template = get_renderer('qrevent:templates/template.pt').implementation()

    def login(self):
        form = forms.LoginForm(self.request.POST)
        if self.request.method == 'POST' and form.validate():
            username = form.username.data
            password = form.password.data
            if models.Account.check_user(username, password):
                headers = remember(self.request, username)
                self.request.session.flash('Welcome back!')
                return HTTPFound(self.request.route_url('record.list'), headers=headers)
        return {'form':form,
                'template':self.template}

    def logout(self):
        headers = forget(self.request)
        self.request.session.flash("Goodbye. We'll see you soon")
        return HTTPFound(self.request.route_url('home'), headers=headers)

def record_include(config):
    config.add_route('home', '/')
    config.add_view(Record, attr='list',
                    route_name='home',
                    renderer='qrevent:templates/record/list.pt',
                    permission=PERMISSION)

    config.add_route('record.list', '/record/list')
    config.add_view(Record, attr='list',
                    route_name='record.list',
                    renderer='qrevent:templates/record/list.pt',
                    permission=PERMISSION)
    
    config.add_route('record.new', '/record/new')
    config.add_view(Record, attr='new',
                    route_name='record.new',
                    renderer='qrevent:templates/record/new.pt',
                    permission=PERMISSION)

    config.add_route('record.view', '/record/view')
    config.add_view(Record, attr='view',
                    route_name='record.view',
                    renderer='qrevent:templates/record/view.pt',
                    permission=PERMISSION)
    
    config.add_route('record.update', '/record/update')
    config.add_view(Record, attr='update',
                    route_name='record.update',
                    renderer='qrevent:templates/record/update.pt',
                    permission=PERMISSION)

    config.add_route('record.delete', '/record/delete') 
    config.add_view(Record, attr='delete',
                    route_name='record.delete',
                    permission=PERMISSION)
   
class Record(object):
    def __init__(self, request):
        self.request = request
        self.session = models.DBSession()
        self.template = get_renderer('qrevent:templates/template.pt').implementation()

    def list(self):
        records = self.session.query(models.QrCode).all()
        return {'records':records,
                'template':self.template}

    def new(self):
        form = forms.RecordForm(self.request.POST)
        if self.request.method == 'POST' and form.validate():
            record = models.QrCode()
            record.qrcode = form.qrcode.data
            record.issuer = form.issuer.data
            self.session.add(record)
            self.session.flush()

            self.request.session.flash('New QR Record created!')
            return HTTPFound(self.request.route_url('record.list'))
        return {'form':form,
                'template':self.template}

    def view(self):
        code_id = self.request.params.get('code_id')
        if not code_id:
            raise HTTPNotFound()

        record = self.session.query(models.QrCode).get(code_id)
        if not record:
            raise HTTPNotFound()

        return {'record':record,
                'template':self.template}

    def update(self):
        code_id = self.request.params.get('code_id')
        if not code_id:
            raise HTTPNotFound()

        record = self.session.query(models.QrCode).get(code_id)
        if not record:
            raise HTTPNotFound()
        
        form = forms.RecordForm(self.request.POST, record)
        if self.request.method == 'POST' and form.validate():
            record.qrcode = form.qrcode.data
            record.issuer = form.issuer.data
            self.session.add(record)
            self.session.flush()

            self.request.session.flash('New QR Record updated!')
            return HTTPFound(self.request.route_url('record.list'))
        return {'form':form,
                'record':record,
                'template':self.template}

    def delete(self):
        code_id = self.request.params.get('code_id')
        if not code_id:
            raise HTTPNotFound()

        record = self.session.query(models.QrCode).get(code_id)
        if not record:
            raise HTTPNotFound()

        self.session.delete(record)
        self.request.session.flash('QR Record deleted!')
        return HTTPFound(self.request.route_url('record.list'))
