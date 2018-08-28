#! /bin/bash

if [ -n "$1" ]; then
    index="-i https://pypi.tuna.tsinghua.edu.cn/simple"
fi
yum install -y python-devel gcc
python download.py
python get-pip.py ${index}
pip install -U ${index} -r requirements.txt

cd mytools && make install
