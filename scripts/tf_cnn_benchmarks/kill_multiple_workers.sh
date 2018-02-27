#!/bin/bash
#
# Author      Kushal Datta
# Created on  January 4th, 2018
# About       Kills zombie processes on multiple nodes
#

ps=skx05-opa
workers='skx06-opa skx07-opa' # skx07-opa skx07-opa'

ssh $ps "killall -9 python"
for w in $workers
do
        ssh $w "killall -9 python"
done
