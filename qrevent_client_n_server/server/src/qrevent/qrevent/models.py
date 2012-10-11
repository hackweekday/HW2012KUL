import os
import base64
import hashlib
import datetime
import transaction

from sqlalchemy import Column, Integer, Unicode
from sqlalchemy import func, DateTime, Boolean
from sqlalchemy import types, ForeignKey

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import engine_from_config
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import synonym, relationship

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class DBConnect(object):
    def __init__(self, **settings):
        self.engine = engine_from_config(settings, 'sqlalchemy.')

    def connect(self):
        Base.metadata.bind = self.engine

    def create(self):
        Base.metadata.create_all(self.engine)

    def populate(self):
        session = DBSession()

        account = Account()
        account.username = u'alphadude'
        account.password = u'helloworld'
        account.is_active = True
        session.add(account)
        session.flush()

        key = AccessKey()
        key.access_key = u'0c36ed7f5a'
        key.private_key = u'28b33a01a3680090c58923e017f4a11a'
        # key.created_by = account.account_id
        session.add(key)
        session.flush()
        
        transaction.commit()

def auto_hash_id(length=32):
    """Create hashed id
    Although any length is supported, it is advided to use minimum 32 character
    to avoid collisions in results.
    """
    def run_hash():
        # Timestamp is the key
        # Because it is better than pure integers
        now = datetime.datetime.now()
        # Generate salt
        salt = os.urandom(1024)
        salt = base64.b64encode(salt)
        # The final key
        combination = str(now) + str(salt)

        # Use corresponding algorithm for specified required length
        # Provides better hash and avoid collisions
        if length == 32:
            func = hashlib.md5
        elif length == 40:
            func = hashlib.sha1
        elif length == 56:
            func = hashlib.sha224
        elif length == 64:
            func = hashlib.sha256
        elif length == 96:
            func = hashlib.sha384
        else:
            func = hashlib.sha512
        hashid = func(combination).hexdigest()
        return unicode(hashid[:length])
    return run_hash

# class JsonType(types.MutableType, types.TypeDecorator):
#     impl = types.Unicode

#     def process_bind_param(self, value, engine):
#         return unicode(simplejson.encode(value))

#     def process_result_value(self, value, engine):
#         if value:
#             return simplejson.decode(value)
#         else:
#             return {}

class Account(Base):
    __tablename__ = 'accounts'

    account_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(Unicode, nullable=False)
    _password = Column('password', Unicode, nullable=False)
    is_active = Column(Boolean, server_default='0')

    def _set_password(self, password):
        if isinstance(password, unicode):
            password = password.encode('utf-8')
        salt = hashlib.sha1(os.urandom(1024)).hexdigest()
        digest = hashlib.sha1(salt + password).hexdigest()
        hpassword = digest + salt
        
        if not isinstance(hpassword, unicode):
            hpassword = hpassword.decode('utf-8')
        self._password = hpassword

    def _get_password(self):
        return self._password

    def validate_password(self, password):
        target = self.password[:40]
        salt = self.password[40:]
        digest = hashlib.sha1(salt + password).hexdigest()
        return digest == target

    @classmethod
    def check_user(self, username, password):
        session = DBSession()
        user = (session.query(Account)
                .filter(Account.username==username)
                .filter(Account.is_active==True)
                .first())
        if user:
            return user.validate_password(password)
        return False

    password = synonym('_password', descriptor=property(_get_password,
                                                        _set_password))
    
class AccessKey(Base):
    __tablename__ = 'access_keys'

    key_id = Column(Unicode, primary_key=True, default=auto_hash_id())
    access_key = Column(Unicode, unique=True, default=auto_hash_id(10))
    private_key = Column(Unicode, default=auto_hash_id())
    create_by = Column(Integer, ForeignKey('accounts.account_id', onupdate='CASCADE', ondelete='CASCADE'))
    is_active = Column(Boolean, server_default='0')

    def revoke_access(self):
        self.is_active = False

    def enable_access(self):
        self.is_active = True

    def regen_private_key(self):
        self.private_key = auto_hash_id()()

    def regen_access_key(self):
        self.access_key = auto_hash_id(10)()

class QrCode(Base):
    __tablename__ = 'qr_codes'

    code_id = Column(Integer, autoincrement=True, primary_key=True)
    qrcode = Column(Unicode, nullable=False)
    # action = Column(JsonType)
    issuer = Column(Unicode, nullable=False, server_default='Anonymous')
    # create_by = Column(Integer, ForeignKey('accounts.account_id', onupdate='CASCADE', ondelete='CASCADE'))
