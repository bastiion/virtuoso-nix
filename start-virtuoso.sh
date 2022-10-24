#!/usr/bin/env bash

trap 'rm -f "$PROPERTY_FILE"' EXIT

PROPERTY_FILE=$(mktemp --suffix .ini)

while getopts ":h?d:l:t:a:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: [-d stateDir] [-l listenAddress] [-t httpListenAddress] [-a dirsAllowed]"
        exit 0
        ;;
    d)  stateDir=$OPTARG
        ;;
    l)  listenAddress=$OPTARG
        ;;
    t)  httpListenAddress=$OPTARG
        ;;
    a)  dirsAllowed=$OPTARG
        ;;
    esac
done

stateDir=${stateDir:-/var/lib/virtuoso/db}
listenAddress=${listenAddress:-localhost:8890}
httpListenAddress=${httpListenAddress:-localhost:8891}

cat <<EOF > "$PROPERTY_FILE"
[Database]
DatabaseFile=${stateDir}/x-virtuoso.db
TransactionFile=${stateDir}/x-virtuoso.trx
ErrorLogFile=${stateDir}/x-virtuoso.log
xa_persistent_file=${stateDir}/x-virtuoso.pxa
[Parameters]
ServerPort=${listenAddress}
${dirsAllowed:+DirsAllowed=${dirsAllowed}}
[HTTPServer]
ServerPort=${httpListenAddress}
EOF

echo "Starting Virtuoso with the following configuration:"
echo "=================================================="
cat "$PROPERTY_FILE"
echo virtuoso-t +foreground +configfile "$PROPERTY_FILE"
virtuoso-t +foreground +configfile "$PROPERTY_FILE" +debug
