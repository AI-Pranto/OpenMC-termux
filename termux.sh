#!/bin/bash

clear

pkg update && pkg upgrade -y

# Dependency install
pkg install cmake \
	clang \
	wget \
	libhdf5-static \
	vim -y

# openmc install
mkdir -p $HOME/openmc_root
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd openmc && mkdir bld && cd bld
cmake -DCMAKE_INSTALL_PREFIX=$HOME/openmc_root ..
make -j 8 install
echo 'export PATH=$HOME/openmc_root/bin:$PATH' >> $PREFIX/etc/bash.bashrc && cd ~

# Download data library
wget -q -O - https://anl.box.com/shared/static/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz | tar -C $HOME -xJ
echo 'export OPENMC_CROSS_SECTIONS=$HOME/nndc_hdf5/cross_sections.xml' >> $PREFIX/etc/bash.bashrc
source $PREFIX/etc/bash.bashrc

# Run pin cell problem
cd $HOME/OpenMC-termux/xml-file && openmc
