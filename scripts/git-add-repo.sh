#! /bin/bash

if [ ! -f ~/.gitrepos ]; then
    touch ~/.gitrepos
fi

if ! grep $PWD ~/.gitrepos; then
    echo $PWD >> ~/.gitrepos
fi
