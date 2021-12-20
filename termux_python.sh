#!/bin/bash

clear
pkg update && pkg upgrade -y

wget -P $HOME https://its-pointless.github.io/setup-pointless-repo.sh
bash $HOME/setup-pointless-repo.sh -y

pkg install build-essential \
	clang \
	cmake \
	fftw \
	freetype \
	libpng \
	libzmq \
	gcc-10 \
	git \
	libgfortran5-10 \
	libgmp \
	libmpc \
	libmpfr \
	libhdf5-static \
	libxml2 \
	libxslt \
	libjpeg-turbo \
	openblas \
	pkg-config \
	python \
	vim \
	wget \
	zlib -y

# setup gcc
setupgcc-10

pip install --upgrade pip

# Install numpy
LDFLAGS=" -lm -lcompiler_rt" pip install numpy

# Install Cython, ipython, lxml, h5py
pip install cython \
			h5py \
			ipython \
			lxml \
			pybind11 \
			pythran \
			uncertainties

# Install pandas
LDFLAGS=" -lm -lcompiler_rt" pip install pandas

# pillow
LDFLAGS="-L/system/lib64/" CFLAGS="-I/data/data/com.termux/files/usr/include/" pip install Pillow

# matplotlib
CFLAGS=" -I/data/data/com.termux/files/usr/include/freetype2" CPPFLAGS=$CFLAGS LDFLAGS=" -lm -lcompiler_rt" pip install matplotlib

# Install scipy
echo 'export BLAS=/data/data/com.termux/files/usr/lib/libblas.so' >> $PREFIX/etc/bash.bashrc
echo 'export LAPACK=/data/data/com.termux/files/usr/lib/liblapack.so' >> $PREFIX/etc/bash.bashrc
LDFLAGS=" -lm -lcompiler_rt" pip install scipy --no-build-isolation

# openmc install
mkdir -p $HOME/opt/OpenMC/build && cd ~/opt/OpenMC
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git && cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/OpenMC ../openmc
make -j${nproc --all} install

# Env variable set for OpenMC
echo 'export PATH=$HOME/opt/OpenMC/bin:$PATH' >> $PREFIX/etc/bash.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/opt/OpenMC/lib:$LD_LIBRARY_PATH' >> $PREFIX/etc/bash.bashrc

# Download HDF5 data
if [[ -z "${OPENMC_CROSS_SECTIONS}" ]]; then
	wget -q -O - https://anl.box.com/shared/static/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz | tar -C $HOME -xJ
fi

# Env variable set for OpenMC
echo 'export PATH=$HOME/opt/OpenMC/bin:$PATH' >> $PREFIX/etc/bash.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/opt/OpenMC/lib:$LD_LIBRARY_PATH' >> $PREFIX/etc/bash.bashrc
echo 'export OPENMC_CROSS_SECTIONS=$HOME/nndc_hdf5/cross_sections.xml' >> $PREFIX/etc/bash.bashrc && source $PREFIX/etc/bash.bashrc

# python API
cd ~/opt/OpenMC/openmc && pip install .

# Run pincell depletion
cd ~/OpenMC-termux/pincell_depletion/run_depletion.py && python run_depletion.py
