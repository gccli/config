#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import logging
import sqlalchemy

"""
  REFERENCE:
    http://docs.sqlalchemy.org/en/latest/core/engines_connections.html
    http://docs.sqlalchemy.org/en/devel/orm/session_basics.html
    http://docs.sqlalchemy.org/en/latest/orm/contextual.html#unitofwork-contextual
"""

def get_db_engine(pool_size=0, **kwargs):
    """
    Engine: throughout the lifespan of an application. maintains both a pool of connections as well as configurations about the database and DBAPI.
    Connection Pooling: maintain long running connections in memory for efficient re-use.

    """
    import pymysql.err
    from sqlalchemy import create_engine
    from sqlalchemy.pool import NullPool
    from . import MY_DB_CONFIG, DBError, InternalError

    try:
        with open(MY_DB_CONFIG, 'r') as fp:
            config = json.load(fp)
            config = config['mysql']
            uri = 'mysql+pymysql://{0}:{1}@{2}:{3}/{4}?charset=utf8'\
                .format(config['username'], config['password'], config['host'],
                        config['port'], config['db'])


            if pool_size > 0:
                engine = create_engine(uri, echo=0,
                                       pool_size=pool_size, pool_timeout=15,
                                       pool_pre_ping=True, **kwargs)
            else:
                engine = create_engine(uri, echo=0,
                                       poolclass=NullPool)
        return engine
    except pymysql.Error as e:
        logging.error(e)
        raise DBError(e.message)
    except Exception as e:
        logging.error(e)
        raise InternalError(e.message)

def get_db_session(engine=None, **kwargs):
    from sqlalchemy.orm import scoped_session, sessionmaker
    try:
        if not engine:
            engine = get_db_engine(**kwargs)

        session_factory = sessionmaker(bind=engine)
        Session = scoped_session(session_factory)
        return Session
    except Exception as e:
        logging.error(e)
        raise
