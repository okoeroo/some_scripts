#!/bin/bash

OPENSSL_VERSION="1.0.1j"

mkdir /tmp/build_openssl
cd /tmp/build_openssl


function download_build() {
curl -O http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xvzf openssl-$OPENSSL_VERSION.tar.gz
mv openssl-$OPENSSL_VERSION openssl_i386
tar -xvzf openssl-$OPENSSL_VERSION.tar.gz
mv openssl-$OPENSSL_VERSION openssl_x86_64

cd openssl_i386
./Configure darwin-i386-cc -shared
make
cd ../
cd openssl_x86_64
./Configure darwin64-x86_64-cc -shared
make
sudo make install
cd ../
}

download_build

lipo -create openssl_i386/libcrypto.1.0.0.dylib openssl_x86_64/libcrypto.1.0.0.dylib -output libcrypto.$OPENSSL_VERSION.dylib
lipo -create openssl_i386/libssl.1.0.0.dylib openssl_x86_64/libssl.1.0.0.dylib -output libssl.$OPENSSL_VERSION.dylib


# rm openssl-$OPENSSL_VERSION.tar.gz


if [ ! -f libcrypto.$OPENSSL_VERSION.dylib ]; then
    echo "libcrypto.$OPENSSL_VERSION.dylib does not exist"
    exit 1
fi

if [ ! -f libssl.$OPENSSL_VERSION.dylib ]; then
    echo "libssl.$OPENSSL_VERSION.dylib does not exist"
    exit 1
fi


echo "Time to install to $INSTALLDIR"
sudo cp libcrypto.$OPENSSL_VERSION.dylib  /usr/local/ssl/lib/
sudo cp libssl.$OPENSSL_VERSION.dylib     /usr/local/ssl/lib/

cd /usr/local/ssl/lib/
sudo ln -s -f libcrypto.$OPENSSL_VERSION.dylib libcrypto.1.0.0.dylib
sudo ln -s -f libssl.$OPENSSL_VERSION.dylib    libssl.1.0.0.dylib
sudo ln -s -f libcrypto.1.0.0.dylib            libcrypto.dylib
sudo ln -s -f libssl.1.0.0.dylib               libssl.dylib


exit 0


# echo "Time to install to $INSTALLDIR"
#sudo cp libcrypto.* /usr/local/lib
#sudo cp libssl.* /usr/local/lib
