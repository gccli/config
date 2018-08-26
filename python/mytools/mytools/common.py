#! /usr/bin/env python

import os
import re
import sys
import json
import logging
import hashlib
from . import NotSupportedError, InternalError

class Hash(object):
    @staticmethod
    def calc(algo, dest):
        if not isinstance(dest, str):
            raise NotSupportedError('Not support calc non-string hash')
        try:
            h = hashlib.new(algo)
            if os.path.isfile(dest):
                with open(dest, 'r') as fp:
                    while True:
                        string = fp.read(4096)
                        if not string: break
                        h.update(string)
            else:
                h.update(dest)

            return h.hexdigest()
        except Exception as e:
            raise InternalError(e.message)

    @staticmethod
    def md5(dest):
        return Hash.calc('md5', dest)

    @staticmethod
    def sha1(dest):
        return Hash.calc('sha1', dest)

    @staticmethod
    def sha256(dest):
        return Hash.calc('sha256', dest)
