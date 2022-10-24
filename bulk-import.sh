#!/usr/bin/env bash

while getopts ":h?i:p:u:w:g:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: [-i inputDir] [-p port] [-u username] [-w password]"
        exit 0
        ;;
    i)  inputDir=$OPTARG
        ;;
    p)  port=$OPTARG
        ;;
    u)  username=$OPTARG
        ;;
    w)  password=$OPTARG
        ;;
    g)  graphURL=$OPTARG
        ;;
    esac
done


echo "Executing bulk loader script."
SECONDS=0
isql ${port} ${username} ${password} exec="ld_dir_all('${inputDir}', '*.ttl', '${graphURL}');"
isql ${port} ${username} ${password} exec="rdf_loader_run();"
isql ${port} ${username} ${password} exec="checkpoint;"
echo "Bulk loader: Finished after ${SECONDS} seconds."