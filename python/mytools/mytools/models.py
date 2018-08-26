#! /usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from sqlalchemy.ext.declarative import declarative_base, DeferredReflection
from sqlalchemy.orm import relationship

Base = declarative_base(cls=DeferredReflection)

class Setting(Base):
    __tablename__ = 'setting'

    def __repr__(self):
        return "<Setting ({0}={1})>".format(self.key, self.value)

def prepare(engine):
    Base.prepare(engine)
