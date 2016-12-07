#!/bin/bash

# execute script with leading .
# set custom varibales 
export GOPATH="$HOME/go"
GOETHEREUMPATH="$GOPATH/src/github.com/ethereum/go-ethereum/"
export DATADIR="$HOME/tmp/BZZ/oib2"
BZZKEYPASS="123"
ENODE1="enode://2eaefb785c27474f9422eb7360dd20d18054d0f2266a2f51a4c953d9209e3657e4f371ee7d9ce3630c22bd8c0a7e6b9d7f528f18c9c53cc5ec7d95c6c3a83b1a@192.168.0.15:30399"
cd $GOETHEREUMPATH

echo "extip:"
# EXTIP=$(lwp-request -o text checkip.dyndns.org | awk '{ print $NF }')
EXTIP=80.109.34.145
echo "$EXTIP"

GETHCMD="nohup ./geth --datadir $DATADIR --unlock 0 --password <(echo -n $BZZKEYPASS) --verbosity 6 --networkid 8158 --nat extip:$EXTIP --nodiscover 2>> $DATADIR/geth.log &"
echo $GETHCMD
#$GETHCMD
nohup ./geth --datadir $DATADIR --unlock 0 --password <(echo -n $BZZKEYPASS) --verbosity 6 --networkid 8158 --nat extip:$EXTIP --nodiscover 2>> $DATADIR/geth.log &

# wait
for ((i=10;i>0;i--)); do
    echo $i
    sleep 1
done

# GETHADDPEER="./geth --exec 'admin.addPeer($ENODE1)' attach ipc:$DATADIR/geth.ipc"
# echo $GETHADDPEER
# ./geth --exec "admin.addPeer($ENODE1)" attach ipc:$DATADIR/geth.ipc

# # wait
# for ((i=10;i>0;i-)); do
#     echo i
#     sleep 1
# done

BZZKEYCMD="./geth --exec 'eth.accounts[0]' attach ipc:$DATADIR/geth.ipc|cut -b4- | sed 's/.$//'"
echo $BZZKEYCMD
#BZZKEY=$($BZZKEYCMD)
BZZKEY=$(./geth --exec 'eth.accounts[0]' attach ipc:$DATADIR/geth.ipc|cut -b4- | sed 's/.$//')

BZZDCMD="./bzzd --bzzaccount $BZZKEY --datadir $DATADIR --ethapi $DATADIR/geth.ipc 2>> $DATADIR/bzz.log < <(echo -n $BZZKEYPASS) &"
echo $BZZDCMD
#exec $BZZDCMD
./bzzd --bzzaccount $BZZKEY --datadir $DATADIR --ethapi $DATADIR/geth.ipc 2>> $DATADIR/bzz.log < <(echo -n $BZZKEYPASS) &
