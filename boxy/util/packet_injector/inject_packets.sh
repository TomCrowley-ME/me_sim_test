#!/bin/bash

if [ ! $# == 2 ]; then
  echo ""; echo "Usage: $0 <pcap file> <speed>"; echo "";  exit 0 ;
fi

file=$1
interval=$2

echo "Injecting $file packets onto eth0"
sudo bittwist $file -v -i eth0 -m $interval
