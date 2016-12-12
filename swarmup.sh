#!/bin/bash

# 1. customize varibales
# 2. create file "$DATADIR/bzzkeypass.txt" containing your bzzkey password
# 3. execute script with leading .
#
# start custom variables
#----------------------------------------------------------------------
export GOPATH="$HOME/go"
GOETHEREUMPATH="$GOPATH/src/github.com/ethereum/go-ethereum/"
export DATADIR="$HOME/tmp/BZZ/oib2"
BZZKEYPASS="$DATADIR/bzzkeypass.txt"
ENODE1="enode://555996a645c2f08712413c71d5e0bd122c148a1000c5306f71859b1cdd41d4dd6ac6faceb4975d467c1e07923999d7e1d20d9113d1ebbac16f43d1e14a33cd8f@80.109.34.145:30304"
cd $GOETHEREUMPATH
ENODE2="enode://0e2d6bb7942742fa826a78a02d68f6a403f129b318aa030b958086d9bf8457666e0fb08d9a14e95f2fb840fd8e84cc1a2cec878bf03b3bb16b05a39a9eab3018@84.113.201.155:30303"
BZZENODE1="enode://2eaefb785c27474f9422eb7360dd20d18054d0f2266a2f51a4c953d9209e3657e4f371ee7d9ce3630c22bd8c0a7e6b9d7f528f18c9c53cc5ec7d95c6c3a83b1a@80.109.34.145:30399"
#----------------------------------------------------------------------
#end custom variables
#

echo "extip:"
EXTIP=$(lwp-request -o text checkip.dyndns.org | awk '{ print $NF }')
echo "$EXTIP"

GETHCMD="$GOETHEREUMPATH/geth --datadir $DATADIR --unlock 0 --password $BZZKEYPASS --verbosity 3 --networkid 8158 --nat extip:$EXTIP --bootnodes $ENODE1,$ENODE2"
echo $GETHCMD
nohup $GETHCMD  >>$DATADIR/geth.log 2>>$DATADIR/geth.log </dev/null &

# wait
for ((i=10;i>0;i--)); do
    echo -n "$i, "
    sleep 1
done
echo ""

BZZKEYCMD="$GOETHEREUMPATH/geth --exec 'eth.accounts[0]' attach ipc:$DATADIR/geth.ipc | cut -b4- | sed 's/.$//'"
echo $BZZKEYCMD
eval BZZKEY=\`${BZZKEYCMD}\`
echo "bzzkey: " $BZZKEY

BZZDCMD="$GOETHEREUMPATH/bzzd --bzzaccount $BZZKEY --datadir $DATADIR --ethapi $DATADIR/geth.ipc"
echo $BZZDCMD

$BZZDCMD 2>> $DATADIR/bzz.log < <(echo -n `<$BZZKEYPASS`) &

# wait
for ((i=30;i>0;i--)); do
    echo -n "$i, "
    sleep 1
done
echo ""

BZZADDPEER1="$GOETHEREUMPATH/geth --exec 'admin.addPeer(\"$BZZENODE1\")' attach ipc:$DATADIR/bzzd.ipc"
echo $BZZADDPEER1
$BZZADDPEER1
