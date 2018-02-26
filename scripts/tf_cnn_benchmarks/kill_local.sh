#!/bin/bash
#
# Author      Kushal Datta
# Created on  February 26th, 2018
# About       Kills local zombie Python processes
#

kill -9 $(ps -eaf | grep python | awk '{print $2}')
