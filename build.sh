#!/bin/bash
#####################
# set working dir to location of build.sh to run this script
####################
set -e
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


VERSION="$1"
RELEASE="$2"
FOLDER=./intstream-"$VERSION"-"$RELEASE"

! rm intstream.tar.gz
! rm -rf intstream/
git clone https://github.com/ajcypherint/intstream.git
git checkout tags/$VERSION
cd ./intstream/
tar -X .gitignore --exclude=*_pycache_* --exclude=intstream.tar.gz -zcvf intstream.tar.gz *
mv intstream.tar.gz ../
cd ..


! rm -rf "$FOLDER"
! rm intstream-"$VERSION"-"$RELEASE".deb 
cp -r ./intstream-X.X $FOLDER
sed -i -e "s/\${version}/$VERSION/g" $FOLDER/DEBIAN/control
sed -i -e "s/\${release}/$RELEASE/g" $FOLDER/DEBIAN/control

gzip -kf -S .Debian.gz changelog  
cp changelog.Debian.gz $FOLDER/usr/share/doc/intstream/
tar -xf intstream.tar.gz --directory $FOLDER/usr/share/intstream

sed -i -e 's/\${cwd}/\/usr\/share\/intstream/g' $FOLDER/usr/share/intstream/utility/intstream
sed -i -e 's/\${server_name}/server_name _/g' $FOLDER/usr/share/intstream/utility/intstream

mv $FOLDER/usr/share/intstream/utility/intstream $FOLDER/etc/nginx/sites-available/intstream.conf

chown -R root:root $FOLDER

dpkg-deb --build $FOLDER
lintian intstream-"$VERSION"-"$RELEASE".deb
