#!/bin/bash

$GOETHEREUMPATH/bzzd --bzzaccount $BZZKEY --datadir $DATADIR --ethapi $DATADIR/geth.ipc < <(echo -n "swarm9oib") 2>> $DATADIR/bzz.log &
