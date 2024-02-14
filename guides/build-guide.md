# Build Guide for EasyPeasy 

## Overview

**Hostname**: easypeasy
**Vulnerability 1**: Remote Code Execution
**Vulnerability 2**: Binary Sudo privileges for low priv user
**Admin Username**: root
**Admin Password**: KingOutlookFederation332
**Low Priv Username**: ellie
**Low Priv Password**: CharlesTreePokemon44
**Location of local.txt**: /home/ellie/local.txt
**Value of local.txt**: 2b1b3240f33fea7ce207a18a8c8640d4
**Location of proof.txt**: /root/proof.txt
**Value of proof.txt**: b2e7d04a3074a11a612cd9d8dcbf9124
**FTP archive password**: wombat1
**FTP password**: isabel

## Required Settings

**CPU**: 1 CPU
**Memory**: 1GB
**Disk**: 10GB


## Build Guide

1. Install Linux distro (tested on Ubuntu 20.04 LTS)
2. Enable network connectivity
3. Ensure machine is fully updated by running `apt upgrade`
4. Upload the following files and directories from the `build` directory to `/root`
    - `build.sh`
    - `vulnerable-sites.tar.gz`
    - `ftp-files`
5. Change to `/root` and run `build.sh`