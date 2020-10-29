#!/usr/bin/env bash

rm -rf ../runs/*
rm -rf ../build
rm -f  ../setup/figures/*
rm -f  ../*/generated/*
rm -f  ../input/shared/*.bin

shopt -s extglob
rm -rf ../analysis/* !("*.m")
shopt -u extglob
