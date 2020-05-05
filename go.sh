#!/bin/bash

#// full deployement :   wget -O - https://raw.githubusercontent.com/badbrainIRC/bitcoin/master/go.sh | bash
sudo rm -Rf ~/bitcoin
# generating entropy make it harder to guess the randomness!.
echo "Initializing random number generator..."
random_seed=/var/run/random-seed
# Carry a random seed from start-up to start-up
# Load and then save the whole entropy pool
if [ -f $random_seed ]
then
    sudo cat $random_seed >/dev/urandom
else
    sudo touch $random_seed
fi
sudo chmod 600 $random_seed
poolfile=/proc/sys/kernel/random/poolsize
[ -r $poolfile ] && bytes=`sudo cat $poolfile` || bytes=512
sudo dd if=/dev/urandom of=$random_seed count=1 bs=$bytes

#Also, add the following lines in an appropriate script which is run during the$

# Carry a random seed from shut-down to start-up
# Save the whole entropy pool
echo "Saving random seed..."
random_seed=/var/run/random-seed
sudo touch $random_seed
sudo chmod 600 $random_seed
poolfile=/proc/sys/kernel/random/poolsize
[ -r $poolfile ] && bytes=`sudo cat $poolfile` || bytes=512
sudo dd if=/dev/urandom of=$random_seed count=1 bs=$bytes

# Create a swap file

cd ~
if [ -e /swapfile1 ]
then
echo "Swapfile already present"
else
sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=1024288
sudo mkswap /swapfile1
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo swapon /swapfile1
fi

# Install dependency

sudo apt-get -y install software-properties-common

sudo add-apt-repository -y ppa:bitcoin/bitcoin

sudo apt-get update

sudo apt-get -y install libcanberra-gtk-module

# Dont need to check if bd is already installed, will override or pass by
#results=$(find /usr/ -name libdb_cxx.so)
#if [ -z $results ]; then
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
#else
#grep DB_VERSION_STRING $(find /usr/ -name db.h)
#echo "BerkeleyDb will not be installed its already there...."
#fi

sudo apt-get -y install libtool autotools-dev automake pkg-config libssl-dev libevent-dev

sudo apt-get -y install bsdmainutils git libboost-all-dev libminiupnpc-dev libqt5gui5

sudo apt-get -y install libqt5core5a libqt5dbus5 libevent-dev qttools5-dev

sudo apt-get -y install qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev

sudo apt-get -y install zlib1g-dev libseccomp-dev libcap-dev libncap-dev

sudo apt-get -y install libunivalue-dev libzmq3-dev

sudo apt-get -y install g++ build-essential

# Keep current version of libboost if already present
results=$(find /usr/ -name libboost_chrono.so)
if [ -z $results ]
then
sudo apt-get -y install libboost-all-dev
else
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
echo "${green}Libboost will not be installed its already there....${reset}"
grep --include=*.hpp -r '/usr/' -e "define BOOST_LIB_VERSION"
fi

sudo apt-get -y install --no-install-recommends gnome-panel

sudo apt-get -y install lynx

sudo apt-get -y install unzip

sudo apt-get -y install sed

cd ~

#// Compile Berkeley if 4.8 is not there
if [ -e /usr/lib/libdb_cxx-4.8.so ]
then
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
echo "${green}BerkeleyDb already present...$(grep --include *.h -r '/usr/' -e 'DB_VERSION_STRING')${reset}" 
else
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz 
tar -xzvf db-4.8.30.NC.tar.gz
result2=$(cat /etc/issue | grep -Po '19.04')
if [ $result2 = "19.04" ]
then
sed -i 's/__atomic_compare_exchange/__db_atomic_compare_exchange/g' ~/db-4.8.30.NC/dbinc/atomic.h
fi
result3=$(cat /etc/issue | grep -Po '4.6')
if [ $result3 = "4.6" ]
then
sed -i 's/__atomic_compare_exchange/__db_atomic_compare_exchange/g' ~/db-4.8.30.NC/dbinc/atomic.h
fi
result4=$(cat /etc/issue | grep -Po 'Ermine')
if [ $result4 = "Ermine" ]
then
sed -i 's/__atomic_compare_exchange/__db_atomic_compare_exchange/g' ~/db-4.8.30.NC/dbinc/atomic.h
fi

rm db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix 
../dist/configure --enable-cxx
make 
sudo make install 
sudo ln -s /usr/local/BerkeleyDB.4.8/lib/libdb-4.8.so /usr/lib/libdb-4.8.so
sudo ln -s /usr/local/BerkeleyDB.4.8/lib/libdb_cxx-4.8.so /usr/lib/libdb_cxx-4.8.so
cd ~
sudo rm -Rf db-4.8.30.NC
#sudo ldconfig
fi

#// Check if libboost is present

results=$(find /usr/ -name libboost_chrono.so)
if [ -z $results ]
then
sudo rm download
     wget https://sourceforge.net/projects/boost/files/boost/1.67.0/boost_1_67_0.zip/download 
     unzip -o download
     cd boost_1_67_0
	sh bootstrap.sh
	sudo ./b2 install
	cd ~
	sudo rm download 
	sudo rm -Rf boost_1_67_0
	#sudo ln -s $(dirname "$(find /usr/ -name libboost_chrono.so)")/lib*.so /usr/lib
	sudo ldconfig
        #sudo rm /usr/lib/libboost_chrono.so
else
     echo "Libboost found..." 
     grep --include=*.hpp -r '/usr/' -e "define BOOST_LIB_VERSION"
fi

#// Clone files from repo, Permissions and make

git clone --recurse-submodules https://github.com/bitcoin/bitcoin.git
cd ~
cd bitcoin
cd ~/src/bitcoin
find . -type f -print0 | xargs -0 sed -i 's/bitcoin/bitcoinevolution/g'
find . -type f -print0 | xargs -0 sed -i 's/Bitcoin/BitcoinEvolution/g'
find . -type f -print0 | xargs -0 sed -i 's/BitCoin/BitCoinEvolution/g'
find . -type f -print0 | xargs -0 sed -i 's/BITCOIN/BITCOINEVOLUITON/g'
find . -type f -print0 | xargs -0 sed -i 's/BTC/BTCev/g'
find . -type f -print0 | xargs -0 sed -i 's/btc/BTCev/g'
find . -type f -print0 | xargs -0 sed -i 's/Btc/BTCev/g'

./autogen.sh
chmod 777 ~/bitcoin/share/genbuild.sh
chmod 777 ~/bitcoin/src/leveldb/build_detect_platform

grep --include=*.hpp -r '/usr/' -e "define BOOST_LIB_VERSION"

sudo rm wrd01.txt
sudo rm wrd00.txt
sudo rm words
find /usr/ -name libboost_chrono.so > words
split -dl 1 --additional-suffix=.txt words wrd

if [ -e wrd01.txt ]
then
echo 0. $(cat wrd00.txt)
echo 1. $(cat wrd01.txt)
echo 2. $(cat wrd02.txt)
echo 3. $(cat wrd03.txt)
echo -n "Choose libboost library to use(0-3)?"
read answer
else
echo "There is only 1 libboost library present. We choose for you 0"
answer=0
fi

echo "You have choosen $answer"

if [ $(dirname "$(cat wrd00.txt)") = "/usr/lib/arm-linux-gnueabihf" ]
then
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
echo "${green}ARM cpu detected --disable-sse2${reset}"
txt=$(echo "--disable-sse2")
sed -i 's/#include <emmintrin.h>//g' ~/bitcoinevolution/src/crypto/pow/scrypt-sse2.cpp
else
txt=$(echo "")
fi

if [ -d /usr/local/BerkeleyDB.4.8/include ]
then
cd bitcoin
./configure CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" CPPFLAGS="-I/usr/local/BerkeleyDB.4.8/include -O2" LDFLAGS="-L/usr/local/BerkeleyDB.4.8/lib" --with-gui=qt5 --with-boost-libdir=$(dirname "$(cat wrd0$answer.txt)") --disable-bench --disable-tests --disable-gui-tests --without-miniupnpc $txt
echo "Using Berkeley Generic..."
else
cd bitcoin
./configure CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" CPPFLAGS="-O2" --with-gui=qt5 --with-boost-libdir=$(dirname "$(cat wrd0$answer.txt)") --disable-bench --disable-tests --disable-gui-tests --without-miniupnpc $txt

echo "Using default system Berkeley..."
fi

#make -j$(nproc) USE_UPNP=-
make USE_UPNP=-

if [ -e ~/bitcoinevolution/src/qt/bitcoin-qt ]
then
sudo strip ~/bitcoinevolution/src/bitcoind
sudo strip ~/bitcoinevolution/src/qt/bitcoin-qt
sudo make install
else
echo "Compile fail not bitcoin-qt present"
fi

cd ~

