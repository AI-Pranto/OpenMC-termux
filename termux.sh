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
mkdir -p $HOME/opt/OpenMC/build && cd ~/opt/OpenMC
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git && cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/OpenMC ../openmc
make -j${nproc --all} install

# Download HDF5 data
if [[ -z "${OPENMC_CROSS_SECTIONS}" ]]; then
	wget -q -O - https://anl.box.com/shared/static/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz | tar -C $HOME -xJ
fi

# Env variable set for OpenMC
echo 'export PATH=$HOME/opt/OpenMC/bin:$PATH' >> $PREFIX/etc/bash.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/opt/OpenMC/lib:$LD_LIBRARY_PATH' >> $PREFIX/etc/bash.bashrc
echo 'export OPENMC_CROSS_SECTIONS=$HOME/nndc_hdf5/cross_sections.xml' >> $PREFIX/etc/bash.bashrc && source $PREFIX/etc/bash.bashrc

# Run pin cell problem
cd $HOME/OpenMC-termux/xml-file && openmc
