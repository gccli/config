#! /bin/bash

yum install -y python-devel
python download.py
python get-pip.py -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

cd mytools && make install
