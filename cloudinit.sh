#! /bin/bash

# curl -L git.io/cloudinit|bash

yum install -y git
[ ! -d config ] && git clone https://github.com/gccli/config.git && cd config && ./config.sh
