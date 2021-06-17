#!/bin/bash

case $1 in
  minor) echo 0 ;;
  major) echo 0 ;;
  *) echo "incorrect argument" && exit 1 ;;
esac
