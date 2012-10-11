"""Create the application's database.

Run this once after installing the application::

    python -m qrevent.scripts.initdb development.ini
"""
import logging.config
import sys

from decimal import Decimal

from pyramid.paster import get_app

from qrevent import models

def main():
    if len(sys.argv) != 2:
        sys.exit("Usage: python -m qrevent.scripts.initdb INI_FILE")
    ini_file = sys.argv[1]
    logging.config.fileConfig(ini_file)
    log = logging.getLogger(__name__)
    app = get_app(ini_file, "main")

    try:
        settings = app.registry.settings
    except AttributeError:
        settings = app.app.registry.settings
    
    db = models.DBConnect(**settings)
    db.connect()
    db.create()
    db.populate()

if __name__ == "__main__":  
    main()
