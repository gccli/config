#! /bin/bash

if ! grep $PWD ~/.gitrepos; then
    echo $PWD >> ~/.gitrepos
fi
