#!/bin/bash

clear
pkg update && pkg upgrade -y

wget -P $HOME https://its-pointless.github.io/setup-pointless-repo.sh
bash $HOME/setup-pointless-repo.sh

pkg install build-essential \
	clang \
	cmake \
	fftw \
	freetype \
	libpng \
	libzmq \
	gcc-10 \
	git \
	libgfortran \
	libgmp \
	libmpc \
	libmpfr \
	libhdf5-static \
	libxml2 \
	libxslt \
	libjpeg-turbo \
	pkg-config \
	python \
	vim \
	wget \
	zlib -y

# setup gcc
setupgcc-10

pip install --upgrade pip
pkg install numpy \
			scipy

# numpy, scipy, cython, h5py, lxml, ipython install
pip install cython \
			ipython \
			lxml \
			h5py \
			numpy \
			scipy

# pandas
export CFLAGS="-Wno-deprecated-declarations -Wno-unreachable-code" && pip install pandas
LDFLAGS=" -lm -lcompiler_rt" pip install pandas

# matplotlib
CFLAGS=" -I/data/data/com.termux/files/usr/include/freetype2" CPPFLAGS=$CFLAGS LDFLAGS=" -lm -lcompiler_rt" pip install matplotlib

# pillow
LDFLAGS="-L/system/lib/" CFLAGS="-I/data/data/com.termux/files/usr/include/" pip install Pillow

# openmc install
mkdir -p $HOME/opt/OpenMC/build && cd ~/opt/OpenMC
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/OpenMC ../openmc
make -j${nproc --all} install

# Env set for OpenMC
echo 'export PATH=$HOME/opt/OpenMC/bin:$PATH' >> $PREFIX/etc/bash.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/opt/OpenMC/lib:$LD_LIBRARY_PATH' >> $PREFIX/etc/bash.bashrc

# Download HDF5 data
wget -q -O - https://anl.box.com/shared/static/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz | tar -C $HOME -xJ

echo 'export OPENMC_CROSS_SECTIONS=$HOME/nndc_hdf5/cross_sections.xml' >> $PREFIX/etc/bash.bashrc
source $PREFIX/etc/bash.bashrc

# python API
cd ~/opt/OpenMC/openmc
pip install .

# Run pincell depletion
cd ~/OpenMC-termux/pincell_depletion/run_depletion.py && python run_depletion.py
