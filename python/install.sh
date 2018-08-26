#! /bin/bash

python download.py
python get-pip.py -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

cd mytools && make install
