from wtforms import Form, TextField, PasswordField
from wtforms import validators

from qrevent import models

class LoginForm(Form):
    username = TextField('Username', [validators.Required()])
    password = PasswordField('Password', [validators.Required()])

class RecordForm(Form):
    qrcode = TextField('QRCode content', [validators.Required()])
    issuer = TextField('Issued by', [validators.Required()])
