#!/bin/bash

OS=ubuntu/trusty64
ITERATION=1
STATUS_ANSWER=1

echo "test machine will be created"
while test $STATUS_ANSWER -ne 0 ; do
	if test $STATUS_ANSWER -eq 1 ; then
		read -p "choose your os between Debian, Ubuntu, Centos : " ANS
		ANSWER=`echo "$ANS" | tr '[:upper:]' '[:lower:]'`
		if test "${ANSWER}" = "debian" ; then
			OS=debian/jessie64
			STATUS_ANSWER=2
		fi
		if test "${ANSWER}" = "ubuntu" ; then
			OS=ubuntu/bionic64
			STATUS_ANSWER=2
		fi
		if test "${ANSWER}" = "centos" ; then
			OS=centos/7
			STATUS_ANSWER=2
		fi
	elif test $STATUS_ANSWER -eq 2 ; then
		read -p "choose number of machines (each of them will use 2cpu and 3Gram) : " ANSWER
		if test ${ANSWER} -ge 0 ; then
			ITERATION=$ANSWER
			STATUS_ANSWER=0
		fi
	fi
done;

rm Vagrantfile
touch Vagrantfile

cat >> Vagrantfile << EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

EOF

for c in $(seq 1 $ITERATION) ; do
	cat >> Vagrantfile << EOF
TEST${c}_IP               = '192.168.56.10${c}'
EOF
done

cat >> Vagrantfile << EOF
OS                      = "$OS"

Vagrant.configure("2") do |config|

  config.ssh.insert_key = true

EOF

for i in $(seq 1 $ITERATION) ; do
	cat >> Vagrantfile << EOF
# define TEST${i} server
  config.vm.define "test${i}" do |test${i}|
    test${i}.vm.hostname = "machine-test${i}"
    test${i}.vm.box = OS
    test${i}.vm.network "private_network", ip: TEST${i}_IP
    test${i}.vm.provider "virtualbox" do |v|
      v.name = "test${i}"
      v.cpus = 2
      v.memory = 3072
    end
    config.vm.provision "file", source:"~/.ssh/id_rsa.pub", destination:"~/.ssh/authorized_keys"
  end

EOF
done

echo "end" >> Vagrantfile

vagrant up
