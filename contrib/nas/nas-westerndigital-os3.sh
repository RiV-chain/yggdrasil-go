#!/bin/sh

# This is a lazy script to create a .bin for WD NAS build.
# You can give it the PKGARCH= argument
# i.e. PKGARCH=armv7hf contrib/nas/nas-westerndigital-os5.sh

if [ `pwd` != `git rev-parse --show-toplevel` ]
then
  echo "You should run this script from the top-level directory of the git repo"
  exit 1
fi

PKGBRANCH=$(basename `git name-rev --name-only HEAD`)
PKG=$(sh contrib/semver/name.sh)
PKGVERSION=$(sh contrib/semver/version.sh --bare)
PKGARCH=${PKGARCH-amd64}
PKGNAME=$PKG-$PKGVERSION-$PKGARCH
PKGFOLDER=mesh
PKGREPLACES=mesh

if [ $PKGBRANCH = "master" ]; then
  PKGREPLACES=mesh-develop
fi

if [ $PKGARCH = "arm" ]; then GOOS=linux GOARCH=arm GOARM=5 ./build
else
  echo "Specify PKGARCH=arm"
  exit 1
fi

echo "Building $PKGNAME"

mkdir -p /tmp/$PKGFOLDER/bin/
mkdir -p /tmp/$PKGFOLDER/tmp/
mkdir -p /tmp/$PKGFOLDER/lib/
mkdir -p /tmp/$PKGFOLDER/var/log/
mkdir -p /tmp/$PKGFOLDER/var/lib/mesh

chmod 0775 /tmp/$PKGFOLDER/ -R

echo "coping ui package..."
cp contrib/ui/nas-westerndigital-os5/package/mesh/* /tmp/$PKGFOLDER/ -r
cp contrib/ui/www/* /tmp/$PKGFOLDER/www/ -r

for resolution in 128x128; do
  echo "Converting icon for: $resolution"
  convert -colorspace sRGB ./riv.png -resize $resolution PNG32:/tmp/$PKGFOLDER/ui/mesh.png  && \
  chmod 644 /tmp/$PKGFOLDER/ui/mesh.png
done

cat > /tmp/$PKGFOLDER/apkg.rc << EOF
Package:	mesh
Section:	Apps
Version:	$PKGVERSION
Packager:	RiV Chain
Email:		vadym.vikulin@rivchain.org
Homepage:	https://github.com/RiV-chain/RiV-mesh
Description: RiV-mesh is an early-stage implementation of a fully end-to-end encrypted IPv6
 network. It is lightweight, self-arranging, supported on multiple platforms and
 allows pretty much any IPv6-capable application to communicate securely with
 other RiV-mesh nodes.
AddonShowName:RiV Mesh
Icon: mesh.png
AddonIndexPage: index.html
AddonUsedPort:
InstDepend:
InstConflict:
StartDepend:
StartConflict:
CenterType: 0
UserControl: 1
MinFWVer:
MaxFWVer:
IndividualFlag:
EOF

cp mesh /tmp/$PKGFOLDER/bin
cp meshctl /tmp/$PKGFOLDER/bin
chmod -R 0755 /tmp/$PKGFOLDER/www/assets
chmod -R u+rwX,go+rX,g-w /tmp/$PKGFOLDER
chmod +x /tmp/$PKGFOLDER/*.sh
curent_dir=$(pwd)
echo "current folder=$curent_dir"

cd /tmp/$PKGFOLDER/ && mksapkg -E -s -m WDMyCloudEX4

cp /tmp/WDMyCloudEX4_mesh_$PKGVERSION.bin* $curent_dir

rm -rf /tmp/$PKGFOLDER

cd $curent_dir