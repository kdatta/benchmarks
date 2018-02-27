#!/bin/bash

# Author: Kushal Datta
# Created on: Feb 2nd, 2018

kill -9 `ps | grep train_mcnn | awk '{print $1}'`
