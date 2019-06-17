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
import argparse
import urllib2
from multiprocessing import Pool

def download(row):
    url, etag, last_modify = row[:3]
    dst_cache = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lisp', os.path.basename(url))
    headers = {'If-None-Match': etag} if etag else {}
    req = urllib2.Request(url, headers=headers)

    if time.time() - float(last_modify) < 7*86400:
        print ('use cache')
        return row

    try:
        print ('downloading {0}...'.format(url))
        resp = urllib2.urlopen(req)
        info = resp.info()
        etag = info.get('ETag')
        with open(dst_cache, 'wb') as fp:
            shutil.copyfileobj(resp, fp)
        row[1] = etag
        row[2] = int(time.time())
        print ('{0} created, etag={1}'.format(os.path.basename(dst_cache), etag))
    except urllib2.HTTPError as e:
        print (e.code, e.reason)
        if e.code == 304:
            return
    except urllib2.URLError as e:
        print (e.reason)
    return row

def update(args):
    csv_r = open(args.cache, 'r')

    reader = csv.reader(csv_r, quoting=csv.QUOTE_NONE, quotechar='')
    header = reader.next()
    rows = []
    pool = Pool(processes=8)
    try:
        for r in pool.imap(download, reader):
            rows.append(r)
        if len(rows) > 0:
            csv_write(args.cache, header, rows)
    except Exception as e:
        print(e)
        return 1
    return 0

def reset(args):
    csv_r = open(args.cache, 'r')
    reader = csv.reader(csv_r, quoting=csv.QUOTE_NONE)
    header = reader.next()
    rows = []
    for row in reader:
        row[1]=''
        row[2]='0'
        row[3]=''
        rows.append(row)
    csv_write(args.cache, header, rows)

def parse_cli(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('--cache', default=os.path.join(os.getcwd(), 'emacs/cache.csv'))

    subparsers = parser.add_subparsers(help='sub-command help')
    sub_reset = subparsers.add_parser('reset', help='reset emacs cache files')
    sub_reset.set_defaults(func=reset)

    sub_update = subparsers.add_parser('update', help='udpate emacs cache files')
    sub_update.set_defaults(func=update)

    return parser.parse_args()

def csv_write(filename, header, rows):
    tmpfilename = filename+'.tmp'
    with open(tmpfilename, 'w') as csv_w:
        writer = csv.writer(csv_w, quoting=csv.QUOTE_NONE, quotechar='')
        if (header):
            writer.writerow(header)
        for row in rows:
            writer.writerow(row)
        csv_w.close()
    if os.path.exists(tmpfilename):
        shutil.move(tmpfilename, filename)

def test():
    row = ['https://www.emacswiki.org/emacs/download/column-marker.el', '','0', '']
    download(row, '/tmp/column-marker.el')
    return 0

if __name__ == '__main__':
    args = parse_cli()
    sys.exit(args.func(args))
