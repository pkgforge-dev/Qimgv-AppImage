#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake             \
	exiv2             \
	mpv               \
	ninja             \
	opencv            \
	pipewire-audio    \
	pipewire-jack     \
	qt6-5compat       \
	qt6-imageformats  \
	qt6-multimedia    \
	qt6-svg           \
	qt6-tools

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

# build qimgv manually from the latest stable tag
echo "Building qimgv..."
echo "---------------------------------------------------------------"
git clone https://github.com/easymodo/qimgv.git ./qimgv
cd ./qimgv

git fetch --tags origin
TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
git checkout "$TAG"

mkdir -p ./build
cd ./build
cmake ../ \
	-G Ninja                    \
	-DCMAKE_BUILD_TYPE=Release  \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_LIBDIR=lib
cmake --build ./ -j"$(nproc)"
cmake --install ./

echo "$TAG" > ~/version
