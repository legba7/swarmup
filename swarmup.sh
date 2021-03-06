#!/bin/bash

# 1. customize varibales
# 2. create file "$DATADIR/../bzzkeypass.txt" containing your bzzkey password
# 3. create file "$DATADIR/../genesis.json" custom genesis block
# 4. execute script with leading . and option setup
# 5. execute script with leading . and option swarmsetup
# 5.1 optionaly write BZZKEY in custom genesis block to start with some ether
#
# start custom variables
#----------------------------------------------------------------------
export GOPATH="$HOME/go"
GOETHEREUMPATH="$GOPATH/src/github.com/ethereum/go-ethereum/"
export DATADIR="$HOME/tmp/BZZ/testnet"
BZZKEYPASS="$DATADIR/../bzzkeypass.txt"
GENESIS="$DATADIR/../genesis.json"
NETWORKID=8158
ENODE1="enode://555996a645c2f08712413c71d5e0bd122c148a1000c5306f71859b1cdd41d4dd6ac6faceb4975d467c1e07923999d7e1d20d9113d1ebbac16f43d1e14a33cd8f@80.109.34.145:30304"
cd $GOETHEREUMPATH
ENODE2="enode://0e2d6bb7942742fa826a78a02d68f6a403f129b318aa030b958086d9bf8457666e0fb08d9a14e95f2fb840fd8e84cc1a2cec878bf03b3bb16b05a39a9eab3018@84.113.201.155:30303"
BZZENODE1="enode://2eaefb785c27474f9422eb7360dd20d18054d0f2266a2f51a4c953d9209e3657e4f371ee7d9ce3630c22bd8c0a7e6b9d7f528f18c9c53cc5ec7d95c6c3a83b1a@80.109.34.145:30399"
#----------------------------------------------------------------------
#end custom variables
#

getextip(){
    EXTIP=$(lwp-request -o text checkip.dyndns.org | awk '{ print $NF }')
    echo "--------extip----------------------------"
    echo "EXTIP: $EXTIP"
    }

getbzzkey(){
    BZZKEYCMD="$HOME/go/bin/geth --exec 'eth.accounts[0]' attach ipc:$DATADIR/geth.ipc | cut -b4- | sed 's/.$//'"
    echo "--------bzzkey---------------------------"
    echo $BZZKEYCMD
    eval BZZKEY=\`${BZZKEYCMD}\`
    echo "BZZKEY: " $BZZKEY
}

wait(){
    # wait
    echo "--------wait-----------------------------"
    for ((i=$1;i>0;i--)); do
	echo -n "$i, "
	sleep 1
    done
    echo ""

}

start_node(){

    getextip

    GETHCMD="$HOME/go/bin/geth --datadir $DATADIR --unlock 0 --password $BZZKEYPASS --verbosity 3 --networkid $NETWORKID --nat extip:$EXTIP --bootnodes $ENODE1,$ENODE2 $@"
    echo "--------geth-----------------------------"
    echo $GETHCMD
    nohup $GETHCMD  >>$DATADIR/geth.log 2>>$DATADIR/geth.log </dev/null &

    wait 10

    getbzzkey

    ADDPEER1="$HOME/go/bin/geth --exec 'admin.addPeer(\"$ENODE1\")' attach ipc:$DATADIR/geth.ipc"
    echo "--------geth addPeer-----------------------"
    echo $ADDPEER1
    $ADDPEER1

    ADDPEER2="$HOME/go/bin/geth --exec 'admin.addPeer(\"$ENODE2\")' attach ipc:$DATADIR/geth.ipc"
    echo "--------geth addPeer-----------------------"
    echo $ADDPEER2
    $ADDPEER2
}

stopit(){
    KILLIT="killall -s SIGKILL $1"
    echo "--------kill $1--------------------------"
    echo $KILLIT
    $KILLIT
}

setup_bzzd(){

    stopit geth

    GETHCMD="$HOME/go/bin/geth --datadir $DATADIR --networkid $NETWORKID --unlock 0 --password $BZZKEYPASS --maxpeers 0 --nodiscover --mine --verbosity 4"
    echo "--------geth mine--------------------------"
    echo $GETHCMD
    nohup $GETHCMD  >>$DATADIR/geth.log 2>>$DATADIR/geth.log </dev/null &

    wait 10

    getbzzkey

    BZZDCMD="$HOME/go/bin/swarm --bzzaccount $BZZKEY --datadir $DATADIR --maxpeers 0 --ethapi $DATADIR/geth.ipc"
    echo "--------swarm-------------------------------"
    echo $BZZDCMD
    $BZZDCMD 2>> $DATADIR/bzz.log < <(echo -n `<$BZZKEYPASS`) &

}

start_bzzd(){

    getbzzkey

    BZZDCMD="$HOME/go/bin/swarm --bzzaccount $BZZKEY --datadir $DATADIR --ethapi $DATADIR/geth.ipc"
    echo $BZZDCMD
    $BZZDCMD 2>> $DATADIR/bzz.log < <(echo -n `<$BZZKEYPASS`) &

    wait 30
    
    BZZADDPEER1="$HOME/go/bin/geth --exec 'admin.addPeer(\"$BZZENODE1\")' attach ipc:$DATADIR/bzzd.ipc"
    echo "--------swarm addPeer-----------------------"
    echo $BZZADDPEER1
    $BZZADDPEER1
}

setup(){
    GETHNEWCMD="$GOETHEREUMPATH/geth --datadir $DATADIR --password $BZZKEYPASS account new"
    echo "--------geth account new------------------"
    echo $GETHNEWCMD
    $GETHNEWCMD
    echo ""

    GETHCMD="$GOETHEREUMPATH/geth --datadir $DATADIR --networkid $NETWORKID --maxpeers 0 --nodiscover"
    echo "--------geth-------------------------------"
    echo $GETHCMD
    nohup $GETHCMD  >>$DATADIR/geth.log 2>>$DATADIR/geth.log </dev/null &

    wait 10
    getbzzkey

    #killall -s SIGKILL geth
    stopit geth

    echo "------------------------------------------"
    echo "optionaly write BZZKEY in genesis.json"
    echo "your BZZKEY is: 0x$BZZKEY"
    echo "your genesis.json is expected at: $GENESIS"
    echo "------------------------------------------"
    read -p "Press Return to continue... " -s
    echo ""

    GETHINITCMD="$GOETHEREUMPATH/geth --datadir $DATADIR init $GENESIS"
    echo "--------geth init---------------------------"
    echo $GETHINITCMD
    $GETHINITCMD

    # getextip

    # GETHCMD="$GOETHEREUMPATH/geth --datadir $DATADIR --unlock 0 --password $BZZKEYPASS --verbosity 3 --networkid $NETWORKID --nat extip:$EXTIP --bootnodes $ENODE1,$ENODE2"
    # echo "--------geth bootnodes----------------------"
    # echo $GETHCMD
    # nohup $GETHCMD  >>$DATADIR/geth.log 2>>$DATADIR/geth.log </dev/null &
}

helpinfo(){
    echo "|---------------swarmup------------------|"
    echo "| 1. customize variables in script first |"
    echo "| 2. use option setup                    |"
    echo "| 3. use option swarmsetup               |"
    echo "|--------------commands------------------|"
    echo "| setup               sets a new node up |"
    echo "| swarmsetup    sets a new swarm node up |"
    echo "| start                      starts node |"
    echo "| start cmd        starts node with cmds |"
    echo "| swarm                     starts swarm |"
    echo "| stop                         stop node |"
    echo "| swarmstop                   stop swarm |"
    echo "|----------------------------------------|"
}

args=("$@")
if [ $# -eq 0 ]; then
    helpinfo
else
    case ${args[0]} in
	setup)
	    echo "setup"
	    setup
	    ;;
	swarmsetup)
	    echo "bzzsetup"
	    setup_bzzd
	    ;;
	start)
	    echo "starting node"
	    #start_node ${args[1]}
	    if [ $# -gt 1 ]; then
		GETHCMDS=""
		for ((i=1;i<$#;i++)); do
		    GETHCMDS="$GETHCMDS ${args[i]}"
		done
		start_node $GETHCMDS
	    else
		start_node
	    fi
	    ;;
	swarm)
	    echo "bzz"
	    start_bzzd
	    ;;
	stop)
	    echo "stop geth"
	    stopit geth
	    ;;
	swarmstop)
	    echo "stop bzz"
	    stopit swarm
	    ;;
	*)
	    helpinfo
	    ;;
    esac
fi
