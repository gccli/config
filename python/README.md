Install pip
===========

    # Download get-pip.py
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    chmod +x get-pip.py

    # Show help
    ./get-pip.py --help

    # Install pip
    ./get-pip.py -i https://pypi.tuna.tsinghua.edu.cn/simple

    # Install pip, alternative method
    ./get-pip.py --no-index --find-links=./

Download python dependencies
============================

    ./download.sh

Install python dependencies
===========================

    pip install --no-index --find-links=pydeps -r pydeps/requirements.txt
