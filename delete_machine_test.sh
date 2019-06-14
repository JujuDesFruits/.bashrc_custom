#!/bin/bash 

counter=0
for i in `vagrant global-status | grep virtualbox | awk '{ print $1 }'` ; do 
	vagrant destroy $i
	counter=$((counter+1))
	ssh-keygen -f "/home/${USER}/.ssh/known_hosts" -R "192.168.56.10${counter}"
done
