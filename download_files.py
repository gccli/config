#! /usr/bin/env python

import os
import sys
import csv
import pycurl
import httplib
import functools
import shutil
import subprocess
import cStringIO

class HTTPError(Exception):
    def __init__(self, code, message=None):
        self.code = code
        message = message or httplib.responses.get(code, "Unknown")
        Exception.__init__(self, "HTTP %d: %s" % (self.code, message))

class Response(object):
    def __init__(self, request, code, headers={}, body=''):
        self.request = request
        self.code = code
        self.headers = headers
        self.body = body
        self.effective_url = request.curl.getinfo(pycurl.EFFECTIVE_URL)
        self.request_time= request.curl.getinfo(pycurl.TOTAL_TIME)
        self.num_bytes = request.curl.getinfo(pycurl.SIZE_DOWNLOAD)
        self.server_ip = request.curl.getinfo(pycurl.PRIMARY_IP)

        if self.code < 200 or self.code >= 300:
            self.error = HTTPError(self.code)
        else:
            self.error = None

class Request(object):
    def __init__(self, url, method='GET', headers={}, body=None, **kwargs):
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body

        self.debug = kwargs.get('debug', 0)
        self.verbose = kwargs.get('verbose', 0)

        self.follow_redirects = kwargs.get('follow_redirects', True)
        self.max_redirects = kwargs.get('max_redirects', 5)
        self.gzip_enable = kwargs.get('gzip_enable', False)
        self.connect_timeout = kwargs.get('connect_timeout', 30)
        self.request_timeout = kwargs.get('request_timeout', 60)
        self.ssl_verifypeer = kwargs.get('ssl_verifypeer', 0)

        self.curl = pycurl.Curl()

    def __del__(self):
        self.curl.close()

    def curl_setup(self, resp_body, resp_headers):
        def curl_header_callback(headers, header_line):
            i = header_line.find(':')
            if (i < 0):
                return

            h_key = header_line[:i]
            h_val = header_line[i+1:]
            headers[h_key.strip()] = h_val.strip()

        self.curl.setopt(pycurl.URL, self.url)
        self.curl.setopt(pycurl.HTTPHEADER,
                         ["%s: %s" % i for i in self.headers.iteritems()])

        self.curl.setopt(pycurl.HEADERFUNCTION,
                         functools.partial(curl_header_callback, resp_headers))
        self.curl.setopt(pycurl.WRITEFUNCTION, resp_body.write)

        self.curl.setopt(pycurl.FOLLOWLOCATION, self.follow_redirects)
        self.curl.setopt(pycurl.MAXREDIRS, self.max_redirects)
        self.curl.setopt(pycurl.CONNECTTIMEOUT, int(self.connect_timeout))
        self.curl.setopt(pycurl.TIMEOUT, int(self.request_timeout))
        self.curl.setopt(pycurl.SSL_VERIFYPEER, self.ssl_verifypeer)

        self.curl.setopt(pycurl.VERBOSE, self.verbose)

        if self.gzip_enable:
            self.curl.setopt(pycurl.ENCODING, "gzip,deflate")
        else:
            self.curl.setopt(pycurl.ENCODING, "none")

        # Handle curl's cryptic options for every individual HTTP method
        if self.method in ("POST", "PUT"):
            request_buffer =  cStringIO.StringIO(self.body)
            self.curl.setopt(pycurl.READFUNCTION, request_buffer.read)
            if self.method == "POST":
                def ioctl(cmd):
                    if cmd == pycurl.IOCMD_RESTARTREAD:
                        request_buffer.seek(0)
                self.curl.setopt(pycurl.IOCTLFUNCTION, ioctl)
                self.curl.setopt(pycurl.POSTFIELDSIZE, len(self.body))
            else:
                self.curl.setopt(pycurl.INFILESIZE, len(self.body))

    def request(self):
        resp_body = cStringIO.StringIO()
        resp_headers = {}

        try:
            self.curl_setup(resp_body, resp_headers)
            if self.debug:
                print self.method, self.url,
            self.curl.perform()
            code = self.curl.getinfo(pycurl.HTTP_CODE)
            if self.debug:
                print code
            if code < 200 or code >= 400:
                return None
            return Response(request=self, code=code, headers=resp_headers,
                            body=resp_body.getvalue())
        except pycurl.error as e:
            errno, errstr = e
            print 'PyCURL open {0} error {1} - {2}'.format(self.url, errno, self.curl.errstr())
            return None

def main():
    csv_old = 'files/files.txt'
    csv_new = '/tmp/files.txt'
    csv_r = open(csv_old, 'r')
    csv_w = open(csv_new, 'w')
    reader = csv.reader(csv_r)
    writer = csv.writer(csv_w)
    writer.writerow(reader.next())

    for row in reader:
        dst = os.getenv('HOME')+row[0]
        src = os.getcwd() + '/' + row[1]
        remote = row[2]
        etag = row[3]

        req = Request(row[2], headers={'If-None-Match': etag})
        print 'downloading {0}'.format(remote),
        rsp = req.request()
        if not rsp:
            sys.exit(1)

        print rsp.code
        if rsp.code != 304:
            row[3] = rsp.headers.get('ETag', '')
            open(src, 'wb').write(rsp.body)

        writer.writerow(row)
        print 'cp {0} {1}'.format(src, dst)
        shutil.copyfile(src, dst)

    csv_r.close()
    csv_w.close()
    print 'cp {0} {1}'.format(csv_new, csv_old)
    shutil.copyfile('/tmp/files.txt', 'files/files.txt')

if 1:
    main()
    sys.exit(0)
else:
    url = 'https://www.emacswiki.org/emacs/download/column-marker.el'
    etag = None
    headers = {'If-None-Match': etag} if etag else {}
    req = Request(url, headers=headers, verbose=1)
    rsp = req.get()
    print rsp.code, rsp.headers['ETag']
