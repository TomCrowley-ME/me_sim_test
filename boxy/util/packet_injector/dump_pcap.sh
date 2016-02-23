#!/bin/bash

if [ ! $# == 1 ]; then
  echo ""; echo "Usage: $0 <pcap file>"; echo "";  exit 0 ;
fi

file=$1
tcpdump -ettnnr $file
