#! /bin/bash

# curl -L git.io/cloudinit|bash

yum install -y emacs-nox git tcpdump lrzsz
[ ! -d config ] && git clone https://github.com/gccli/config.git && cd config && ./config.sh
