#! /usr/bin/env python

import sys
import time
import myext

myext.setprocname(' '.join(sys.argv) + ' xxxxxxxxx')
while True:
    time.sleep(1)
