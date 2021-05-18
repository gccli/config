#!/bin/bash

download=${1:-n}
mkdir -p ~/.emacs.d/lisp

if [ -d emacs/lisp ]; then
    /bin/cp emacs/.emacs ~/
    if [ "$download" == "y" ]; then
        python emacs/cache.py update
    fi
    find ~/.emacs.d/lisp -type f | xargs rm -f
    find emacs/lisp -type f | \
        while read line; do
            /bin/cp $line  ~/.emacs.d/lisp
        done
else
    curl https://raw.githubusercontent.com/gccli/config/master/emacs/.emacs > ~/.emacs
    [ $? -ne 0 ] && exit 1
    cd ~/.emacs.d/lisp
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/column-marker.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/go-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/markdown-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/php-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/php-project.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/setup-autoinsert.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/xcscope.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/lisp/yaml-mode.el &
    wait
fi
