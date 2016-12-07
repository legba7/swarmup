#!/bin/bash

BZZKEY=$( $GOETHEREUMPATH/geth --exec 'eth.accounts[0]' attach ipc:$DATADIR/geth.ipc|cut -b4- | sed 's/.$//')

echo $BZZKEY
