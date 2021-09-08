pkg update && pkg upgrade -y

wget -P $HOME https://its-pointless.github.io/setup-pointless-repo.sh
bash $HOME/setup-pointless-repo.sh

pkg install build-essential \
	cmake \
	clang \
	wget \
	libhdf5-static \
	vim \
	python \
	numpy \
	scipy \
	libxml2 \
	libxslt \
	libjpeg-turbo -y

pip install --upgrade pip

# pandas
export CFLAGS="-Wno-deprecated-declarations -Wno-unreachable-code" && pip install pandas

# matplotlib
cd ~
git clone https://github.com/matplotlib/matplotlib.git
cd matplotlib
sed 's@#enable_lto = True@enable_lto = False@g' setup.cfg.template > setup.cfg
pip install .

# lxml
pip install lxml \
	h5py \
	wheel

# pillow
LDFLAGS="-L/system/lib/" CFLAGS="-I/data/data/com.termux/files/usr/include/" pip install Pillow

mkdir -p $HOME/opt/OpenMC/build && cd ~/opt/OpenMC
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/OpenMC ../openmc
make -j 8 install

# Env for OpenMC
echo 'export PATH=$HOME/opt/OpenMC/bin:$PATH' >> $PREFIX/etc/bash.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/opt/OpenMC/lib:$LD_LIBRARY_PATH' >> $PREFIX/etc/bash.bashrc

# Download HDF5 data
if [[ -z "${OPENMC_CROSS_SECTIONS}" ]]; then
	wget -c -P $HOME https://anl.box.com/shared/static/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz
	tar -xvf $HOME/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz -C $HOME
fi

echo 'export OPENMC_CROSS_SECTIONS=$HOME/nndc_hdf5/cross_sections.xml' >> $PREFIX/etc/bash.bashrc
source $PREFIX/etc/bash.bashrc
rm -rf $HOME/teaup95cqv8s9nn56hfn7ku8mmelr95p.xz

# python API
cd ~/opt/OpenMC/openmc
pip install .

# Run pincell depletion
cd ~/OpenMC-termux/pincell_depletion/run_depletion.py && python run_depletion.py
