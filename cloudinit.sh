#! /bin/bash

yum install -y emacs-nox git tcpdump lrzsz
[ ! -d config ] && git clone https://github.com/gccli/config.git
