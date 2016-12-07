#!/bin/bash

nohup $GOETHEREUMPATH/geth --datadir $DATADIR --unlock 0 --password <(echo -n "swarm9oib") --verbosity 3 --networkid 8158 2>> $DATADIR/geth.log &
