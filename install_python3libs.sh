#!/bin/bash

# Print commands and exit on errors.
set -xe

conda install -c conda-forge jupyterlab
conda install networkx scapy numpy pandas matplotlib