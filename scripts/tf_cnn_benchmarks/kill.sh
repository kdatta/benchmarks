#!/bin/bash
#
# Author      Kushal Datta
# Created on  January 4th, 2018
# About       Kills zombie processes on multiple nodes
#

ps=skx05-opa
#workers='skx06-opa skx07-opa skx08-opa skx09-opa'
workers='skx06-opa skx07-opa skx08-opa skx10-opa skx11-opa skx12-opa'

cmd="kill -9 $(ps -eaf | grep python | awk '{print $2}')"
ssh $ps "$cmd"
for w in $workers
do
        ssh $w "$cmd"
done
