#! /usr/bin/env python

import os
import re
import sys
import copy
import json
import logging
import logging.handlers
import subprocess
import unicodedata

from .errors import (MyError, DBError, InternalError, NotSupportedError)

# Global variables
MY_PREFIX='/usr/local'
MY_CONFIG_PATH=os.path.join(MY_PREFIX, 'etc')
MY_DB_CONFIG = os.path.join(MY_CONFIG_PATH, 'db.json')

LOG_COLORS = {
    logging.ERROR:   '\x1b[31m',
    logging.WARNING: '\x1b[33m'
}

class ColorFormatter(logging.Formatter):
    def format(self, record, *args, **kwargs):
        new_record = copy.copy(record)
        if new_record.levelno in LOG_COLORS:
            new_record.levelname = "{color_begin}{level}{color_end}".format(
                level=new_record.levelname,
                color_begin=LOG_COLORS[new_record.levelno],
                color_end='\x1b[0m'
            )
        return super(ColorFormatter, self).format(new_record, *args, **kwargs)

def init_log(name, level=logging.INFO, with_syslog='yes'):
    formatter = ColorFormatter('%(asctime)s.%(msecs)d %(filename)s:%(lineno)s %(levelname)s - %(message)s',
                               datefmt='%H:%M:%S')
    if not name.endswith('.log'):
        name += '.log'
    fh = logging.FileHandler(os.path.join('/var/log', name))
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(formatter)
    logging.getLogger().addHandler(fh)

    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(formatter)
    logging.getLogger().addHandler(ch)

    if with_syslog and with_syslog == 'yes':
        sh = logging.handlers.SysLogHandler(address='/dev/log')
        sh.setLevel(logging.DEBUG)
        sh.setFormatter(formatter)
        logging.getLogger().addHandler(sh)

    logging.getLogger().setLevel(level)

def callproc(command):
    logging.debug('RUN [{0}]'.format(command))
    if isinstance(command, unicode):
        command = unicodedata.normalize('NFKD', command).encode('ascii','ignore')

    p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()

    if p.returncode != 0:
        if not err: err = out
        message = 'Call ({0}) error({1}) - {2}'.format(command, p.returncode, err.strip())
        logging.error(message)
        return (p.returncode, err)

    return (p.returncode, out)

def get_ipaddrs(interfaces):
    addrs = []

    if isinstance(interfaces, list):
        for ifname in interfaces:
            command = '/sbin/ip addr show dev {0}'.format(ifname)
            err, out = callproc(command)
            if err != 0:
                continue
            addrs += re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,}', out)
    else:
        command = '/sbin/ip addr show'
        err, out = callproc(command)
        if err == 0:
            addrs += re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,}', out)

    return [ a.split('/')[0] for a in addrs ]
