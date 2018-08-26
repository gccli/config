#! /usr/bin/env python

import os
import sys
import csv
import time
import pycurl
import httplib
import functools
import shutil
import subprocess
import cStringIO

def download(url, dest):
    """ return code """
    def curl_header_callback(headers, header_line):
        i = header_line.find(':')
        if (i < 0):
            return

        h_key = header_line[:i]
        h_val = header_line[i+1:]
        headers[h_key.strip().lower()] = h_val.strip().lower()

    curl = pycurl.Curl()
    headers = []
    resp_code = -1
    resp_body = cStringIO.StringIO()
    resp_headers = {}
    gzip_enable = 0
    verbose = 1

    dn = os.path.dirname(dest)
    fn = os.path.basename(dest)

    etag = ''
    etag_fn = os.path.join(dn, '.{0}.etag'.format(fn))

    if os.path.exists(etag_fn):
        with open(etag_fn) as fp:
            etag = fp.read()
    try:
        headers.append('If-None-Match: "{0}"'.format(etag))

        print headers
        curl.setopt(pycurl.URL, url)
        curl.setopt(pycurl.HTTPHEADER, headers)
        curl.setopt(pycurl.WRITEFUNCTION, resp_body.write)

        curl.setopt(pycurl.FOLLOWLOCATION, True)
        curl.setopt(pycurl.MAXREDIRS, 5)
        curl.setopt(pycurl.CONNECTTIMEOUT, 15)
        curl.setopt(pycurl.TIMEOUT, 15)
        curl.setopt(pycurl.SSL_VERIFYPEER, 0)

        curl.setopt(pycurl.HEADERFUNCTION,
                         functools.partial(curl_header_callback, resp_headers))
        curl.setopt(pycurl.WRITEFUNCTION, resp_body.write)
        curl.setopt(pycurl.VERBOSE, verbose)

        if gzip_enable:
            curl.setopt(pycurl.ENCODING, "gzip,deflate")
        else:
            curl.setopt(pycurl.ENCODING, "none")

        curl.perform()
        resp_code = curl.getinfo(pycurl.HTTP_CODE)
        if resp_code < 200 or resp_code >= 400:
            print 'Error return code: {0}'.format(resp_code)
        elif resp_code != 304:
            etag = resp_headers.get('etag', '').strip('"')
            print 'Download {0} and write to {1}'.format(url, dest)
            with open(dest, 'wb') as fp:
                resp_body.seek(0)
                shutil.copyfileobj (resp_body, fp)
            with open(etag_fn, 'w') as fp:
                fp.write(etag)

    except Exception as e:
        print e
    finally:
        curl.close()

    return resp_code, etag

if __name__ == '__main__':
    code, etag = download('https://bootstrap.pypa.io/get-pip.py', 'get-pip.py')
    print code, httplib.responses.get(code, "Unknown"), etag
