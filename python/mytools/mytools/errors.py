#! /usr/bin/env python
# -*- coding: utf-8 -*-

class MyError(Exception):
    pass

class DBError(MyError):
    pass

class InternalError(MyError):
    pass

class NotSupportedError(MyError):
    pass
