#!/bin/bash

set -x

if [ -z "$1" ]
  then
    echo "No version"
    exit 1
fi

if [ -z "$2" ]
  then
    echo "No release"
    exit 1
fi

! rm intstream.tar.gz

cd ../intstream/
tar -X .gitignore --exclude=*_pycache_* --exclude=intstream.tar.gz -zcvf intstream.tar.gz *
mv intstream.tar.gz ../debintstream/
gzip change
cd ../debintstream/

VERSION="$1"
RELEASE="$2"
FOLDER=./intstream-"$VERSION"-"$RELEASE"

! sudo rm -rf "$FOLDER"
! rm intstream-"$VERSION"-"$RELEASE".deb 
cp -r ./intstream-X.X $FOLDER
sed -i -e "s/\${version}/$VERSION/g" $FOLDER/DEBIAN/control
sed -i -e "s/\${release}/$RELEASE/g" $FOLDER/DEBIAN/control

gzip -kf -S .Debian.gz changelog  
cp changelog.Debian.gz $FOLDER/usr/share/doc/intstream/
tar -xf intstream.tar.gz --directory $FOLDER/usr/share/intstream
chown -R root:root $FOLDER

dpkg-deb --build $FOLDER
lintian intstream-"$VERSION"-"$RELEASE".deb
