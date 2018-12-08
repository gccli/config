#!/bin/bash -ex

if [ -d emacs/lisp ]; then
    find emacs/lisp -type f | \
        while read line; do
            /bin/cp $line  ~/.emacs.d/lisp
        done
    /bin/cp emacs/.emacs ~/
else
    cd ~/
    curl -JO https://raw.githubusercontent.com/gccli/config/master/emacs/.emacs
    cd ~/.emacs.d/lisp
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/column-marker.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/go-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/markdown-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/php-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/php-project.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/yaml-mode.el &
    curl -JO https://raw.githubusercontent.com/gccli/config/master/files/xcscope.el
fi
