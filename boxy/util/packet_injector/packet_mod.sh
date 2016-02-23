#!/bin/bash


if [ $# -lt 3 ] || [ $# -gt 4 ]; then
  echo ""; echo "Usage: $0 <pcap file> <src ip> <dest MAC> [dest ip]"; echo "";  exit 0 ;
fi

file=$1
srcip=$2
destmac=$3

if [ $# == 4 ]; then
  destip="-d $4"
  echo "Setting destination IP address to $4"
else
 destip=""
fi

echo "Setting source IP address to $srcip"
bittwiste -I $file -O $file.mod -T ip -s $srcip $destip
bittwiste -I $file.mod -O $file -T eth -d $destmac
rm $file.mod

echo "done"
